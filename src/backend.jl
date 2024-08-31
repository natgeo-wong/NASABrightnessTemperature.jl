## DateString Aliasing
yrmo2dir(date::TimeType) = Dates.format(date,dateformat"yyyy/mm")
yrmo2str(date::TimeType) = Dates.format(date,dateformat"yyyymm")
yr2str(date::TimeType)   = Dates.format(date,dateformat"yyyy")
ymd2str(date::TimeType)  = Dates.format(date,dateformat"yyyymmdd")

function btdlonlat()
    lon = convert(Array,-179.95:0.1:179.95)
    lat = convert(Array,-89.95:0.1:89.95)
    return lon,lat
end

function checkdates(
    dtbeg :: TimeType,
    dtend :: TimeType
)

    if dtbeg < Date(2000,6,1)
        error("$(modulelog()) - You have specified a date that is before the earliest available date of GPM IMERG data, 2000-06-01.")
    end

    if dtend > (Dates.now() - Day(3))
        error("$(modulelog()) - You have specified a date that is later than the latest available date of GPM IMERG Near-Realtime data, $(now() - Day(3)).")
    end

end

function ncoffsetscale(data::AbstractArray{<:Real})

    init = data[findfirst(!isnan,data)]
    dmax = init
    dmin = init
    for ii in eachindex(data)
        dataii = data[ii]
        if !isnan(dataii)
            if dataii > dmax; dmax = dataii end
            if dataii < dmin; dmin = dataii end
        end
    end

    scale = (dmax-dmin) / 65533;
    offset = (dmax+dmin-scale) / 2;

    return scale,offset

end

function real2int16!(
    outarray :: AbstractArray{Int16},
    inarray  :: AbstractArray{<:Real},
    scale    :: Real,
    offset   :: Real
)

    for ii in eachindex(inarray)

        idata = (inarray[ii] - offset) / scale
        if isnan(idata)
              outarray[ii] = -32767
        else; outarray[ii] = round(Int16,idata)
        end

    end

    return

end

function nanmean(
    data :: AbstractArray,
    dNaN :: AbstractArray
)
    nNaN = length(dNaN)
    for iNaN in 1 : nNaN
        dNaN[iNaN] = !isnan(data[iNaN])
    end
    dataii = @view data[dNaN]
    if !isempty(dataii); return mean(dataii); else; return NaN; end
end

function nanmean(
    data :: AbstractArray,
    dNaN :: AbstractArray,
    wgts :: AbstractArray,
)
    nNaN = length(dNaN)
    for iNaN in 1 : nNaN
        dNaN[iNaN] = !isnan(data[iNaN])
    end
    dataii = view(data,dNaN) .* view(wgts,dNaN)
    wgtsii = view(wgts,dNaN)
    if !isempty(dataii); return sum(dataii) / sum(wgtsii); else; return NaN; end
end