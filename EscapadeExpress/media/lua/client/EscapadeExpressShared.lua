function EE_getNowSeconds()
    if getTimestamp ~= nil then
        return getTimestamp()
    end

    if os and os.time then
        return os.time()
    end

    return math.floor(getGameTime():getWorldAgeHours() * 3600)
end
