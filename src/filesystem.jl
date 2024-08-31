"""
    npdfnc(
        npd :: NASAPrecipitationDataset,
        geo :: GeoRegion,
        dt  :: TimeType
    ) -> String

Returns of the path of the file for the NASA Precipitation dataset specified by `npd` for a GeoRegion specified by `geo` at a date specified by `dt`.

Arguments
=========
- `npd` : a `NASAPrecipitationDataset` specifying the dataset details and date download range
- `geo` : a `GeoRegion` (see [GeoRegions.jl](https://github.com/JuliaClimate/GeoRegions.jl)) that sets the geographic bounds of the data array in lon-lat
- `dt`  : A specified date. The NCDataset retrieved may will contain data for the date, although it may also contain data for other dates depending on the `NASAPrecipitationDataset` specified by `npd`
"""
function btdfnc(
    btd :: TbDataset{ST,DT},
	geo :: GeoRegion,
    dt  :: TimeType
) where {ST<:AbstractString, DT<:TimeType}

    fol = joinpath(btd.path,geo.ID,yrmo2dir(dt))
    fnc = btd.ID * "-" * geo.ID * "-" * ymd2str(dt) * ".nc"
    return joinpath(fol,fnc)

end

####

function btdanc(
    btd :: TbDataset{ST,DT},
	geo :: GeoRegion,
    dt  :: TimeType
) where {ST<:AbstractString, DT<:TimeType}

    fol = joinpath(btd.path,geo.ID)
    fnc = btd.ID * "-" * geo.ID * "-" * yr2str(dt) * ".nc"
    return joinpath(fol,fnc)

end

####

function btdsmth(
    btd :: TbDataset{ST,DT},
	geo :: GeoRegion,
    dt  :: TimeType,
    smoothlon  :: Real,
    smoothlat  :: Real,
    smoothtime :: Int
) where {ST<:AbstractString, DT<:TimeType}

    fol = joinpath(btd.path,geo.ID,yrmo2dir(dt))
    fnc = btd.ID * "-" * geo.ID * "-" * "smooth" * "_" *
          @sprintf("%.2f",smoothlon) * "x" * @sprintf("%.2f",smoothlat) *
          "_" * @sprintf("%02d",smoothtime) * "steps" *
          "-" * ymd2str(dt) * ".nc"
    return joinpath(fol,fnc)

end