dofile "__tests/wow_api.lua"
D_DAYS = "%d |4Day:Days;";
D_HOURS = "%d |4Hour:Hours;";
D_MINUTES = "%d |4Minute:Minutes;";
D_SECONDS = "%d |4Second:Seconds;";
DATE_COMPLETED = "Completed: %s";
DAYS = "|4Day:Days;";
DAYS_ABBR = "%d |4Day:Days;";
DAY_ONELETTER_ABBR = "%d d";
HOURS = "|4Hour:Hours;";
HOURS_ABBR = "%d |4Hr:Hr;";
HOURS_MINUTES_SECONDS = "%.2d:%.2d:%.2d";
HOURS_MINUTES_SECONDS_MILLISECONDS = "%.2d:%.2d:%.2d.%.3d";
HOUR_ONELETTER_ABBR = "%d h";
MINS_ABBR = "Mins";
MINUTES = "|4Minute:Minutes;";
MINUTES_ABBR = "%d |4Min:Min;";
MINUTES_SECONDS = "%.2d:%.2d";
MINUTE_ONELETTER_ABBR = "%d m";
SHORTDATE = "%2d/%02d/%02d";
SHORTDATENOYEAR = "%2%d/%1%02d";
SHORTDATENOYEAR_EU = "%1%d/%2%d";
SHORTDATE_EU = "%1%d/%2%d/%3%02d";
TIMESTAMP_FORMAT_HHMM = "%I:%M ";
TIMESTAMP_FORMAT_HHMMSS = "%I:%M:%S ";
TIMESTAMP_FORMAT_HHMMSS_24HR = "%H:%M:%S ";
TIMESTAMP_FORMAT_HHMMSS_AMPM = "%I:%M:%S %p ";
TIMESTAMP_FORMAT_HHMM_24HR = "%H:%M ";
TIMESTAMP_FORMAT_HHMM_AMPM = "%I:%M %p ";
TIMESTAMP_FORMAT_NONE = "None";
TIME_DAYHOURMINUTESECOND = "%d |4day:days;, %d |4hour:hours;, %d |4minute:minutes;, %d |4second:seconds;";
TIME_ELAPSED = "Time Elapsed:";
TIME_IN_QUEUE = "Time In Queue: %s";
TIME_LABEL = "Time:";
TIME_LEFT_LONG = "Long";
TIME_LEFT_MEDIUM = "Medium";
TIME_LEFT_SHORT = "Short";
TIME_LEFT_VERY_LONG = "Very Long";
TIME_PLAYED_ALERT = "You have been playing for %s. Excessive gameplay can interfere with your daily life.";
TIME_PLAYED_LEVEL = "Time played this level: %s";
TIME_PLAYED_MSG = "Time Played";
TIME_PLAYED_TOTAL = "Total time played: %s";
TIME_REMAINING = "Time Remaining:";
TIME_TEMPLATE_LONG = "%d days, %d hours, %d minutes, %d seconds";
TIME_TO_PORT = "Battleground closing in";
TIME_TO_PORT_ARENA = "Arena closing in";
TIME_TWELVEHOURAM = "%d:%02d AM";
TIME_TWELVEHOURPM = "%d:%02d PM";
TIME_TWENTYFOURHOURS = "%d:%02d";
TIME_UNIT_DELIMITER = " ";


function SecondsToClock(seconds, displayZeroHours)
	seconds = math.max(seconds, 0);
	local hours = math.floor(seconds / 3600);
	seconds = seconds - (hours * 3600);
	local minutes = math.floor(seconds / 60);
	seconds = seconds % 60;
	if hours > 0 or displayZeroHours then
		return string.format(HOURS_MINUTES_SECONDS, hours, minutes, seconds);
	else
		return string.format(MINUTES_SECONDS, minutes, seconds);
	end
end
function SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = roundUp and math.ceil(seconds) or math.floor(seconds);
	maxCount = maxCount or 2;
	if ( seconds >= 86400  ) then
		count = count + 1;
		if ( count == maxCount and roundUp ) then
			tempTime = math.ceil(seconds / 86400);
		else
			tempTime = math.floor(seconds / 86400);
		end
		if ( notAbbreviated ) then
			time = D_DAYS:format(tempTime);
		else
			time = DAYS_ABBR:format(tempTime);
		end
		seconds = math.mod(seconds, 86400);
	end
	if ( count < maxCount and seconds >= 3600  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = math.ceil(seconds / 3600);
		else
			tempTime = math.floor(seconds / 3600);
		end
		if ( notAbbreviated ) then
			time = time..D_HOURS:format(tempTime);
		else
			time = time..HOURS_ABBR:format(tempTime);
		end
		seconds = math.mod(seconds, 3600);
	end
	if ( count < maxCount and seconds >= 60  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = math.ceil(seconds / 60);
		else
			tempTime = math.floor(seconds / 60);
		end
		if ( notAbbreviated ) then
			time = time..D_MINUTES:format(tempTime);
		else
			time = time..MINUTES_ABBR:format(tempTime);
		end
		seconds = math.mod(seconds, 60);
	end
	if ( count < maxCount and seconds > 0 and not noSeconds ) then
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( notAbbreviated ) then
			time = time..D_SECONDS:format(seconds);
		else
			time = time..SECONDS_ABBR:format(seconds);
		end
	end
	return time;
end
function SecondsToTimeAbbrev(seconds)
	local tempTime;
	if ( seconds >= 86400  ) then
		tempTime = math.ceil(seconds / 86400);
		return DAY_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 3600  ) then
		tempTime = math.ceil(seconds / 3600);
		return HOUR_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 60  ) then
		tempTime = math.ceil(seconds / 60);
		return MINUTE_ONELETTER_ABBR, tempTime;
	end
	return SECOND_ONELETTER_ABBR, seconds;
end
function FormatShortDate(day, month, year)
	if (year) then
		if (LOCALE_enGB) then
			return SHORTDATE_EU:format(day, month, year);
		else
			return SHORTDATE:format(day, month, year);
		end
	else
		if (LOCALE_enGB) then
			return SHORTDATENOYEAR_EU:format(day, month);
		else
			return SHORTDATENOYEAR:format(day, month);
		end
	end
end

function GetNumberOfDaysFromNow(oldDate)
	local d, m, y = strsplit("/", oldDate, 3)
	local sinceEpoch = os.time({year = "20"..y, month = m, day = d, hour = 0}) -- convert from string to seconds since epoch
	local diff = os.date("*t", math.abs(os.time() - sinceEpoch)) -- get the difference as a table
	-- Convert to number of d/m/y
	return diff.day - 1, diff.month - 1, diff.year - 1970
end


print("1:",os.date("*t", math.abs(os.time() - 1577149947)))
print("2:", os.date("*t", 1000))

local d = os.date("*t", os.time())
print(FormatShortDate(d.day,d.month,d.year))
print(string.format(SecondsToTimeAbbrev(math.abs(os.time() - 1578149947))))
print(SecondsToTime(math.abs(os.time() - 1578149947)))
print(SecondsToClock(math.abs(os.time() - 1578149947)))
print(GetNumberOfDaysFromNow("31/12/19"))
local tomorrow = os.time({year = "2019", month = 12, day = 30, hour = 0})
print(string.format(SecondsToTimeAbbrev(math.abs(os.time() - tomorrow))))
print(SecondsToTime(math.abs(os.time() - tomorrow)))
print(SecondsToClock(math.abs(os.time() - tomorrow)))
print (1578149947 % (60*60*24))
