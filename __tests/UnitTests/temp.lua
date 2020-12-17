local names = {
    "Potdisc-Ravencrest",
    "Potdisc-Ravencrest-Ravencrest",
    "Barrow-Ravencrest-Ravencrest",
    "Barrow-Ravencrest-Ravencrest-Ravencrest",
    "Someone",
    "совапеппа-СвежевательДуш-СвежевательДуш",
    "совапеппа-СвежевательДуш-СвежевательДуш-СвежевательДуш",
    "совапеппа-СвежевательДуш-СвежевательДуш-СвежевательДуш",
    "совапеппа-СвежевательДуш",
}

for _, name in ipairs(names) do
    local s, e = string.find(name, ".-%-.-%-")
    if s then
        print(string.sub(name, s,e -1))
    end
end