struct TbDataset{ST<:AbstractString, DT<:TimeType}
    ID    :: ST
    name  :: ST
    doi   :: ST
    start :: DT
    stop  :: DT
    path :: ST
    hroot :: ST
    fpref :: ST
    fsuff :: ST
end

function TbDataset(
    ST = String,
    DT = Date;
    start :: TimeType = Date(2000,6),
    stop  :: TimeType = Dates.now() - Day(2),
    path  :: AbstractString = homedir(),
)

    @info "$(modulelog()) - Setting up data structure containing information on Early IMERG Daily data to be downloaded"

    fol = joinpath(path,"imergearlydy"); if !isdir(fol); mkpath(fol) end
    fol = joinpath(path,"imergmask");    if !isdir(fol); mkpath(fol) end

    start = Date(year(start),month(start),1)
    stop  = Date(year(stop),month(stop),daysinmonth(stop))
    checkdates(start,stop)

    return TbDataset{ST,DT}(
		"tb", "Brightness Temperature", "10.5067/P4HZB9N27EKU",
        start, stop,
		joinpath(path,"tb"),
        "https://disc2.gesdisc.eosdis.nasa.gov/opendap/MERGED_IR/GPM_MERGIR.1",
        "merg", "4km-pixel.nc4",
    )

end

function show(
    io  :: IO,
    btd :: TbDataset{ST,DT}
) where {ST<:AbstractString, DT<:TimeType}

    print(
		io,
		"The NASA Brightness Temperature Dataset {$ST,$DT} has the following properties:\n",
		"    Dataset ID           (ID) : ", btd.ID, '\n',
		"    Logging Name       (name) : ", btd.name, '\n',
		"    DOI URL             (doi) : ", btd.doi,   '\n',
		"    Data Directory     (path) : ", btd.path, '\n',
		"    Date Begin        (start) : ", btd.start, '\n',
		"    Date End           (stop) : ", btd.stop , '\n',
		"    Timestep                  : Half Hourly\n",
        "    Data Resolution           : 4 km\n",
        "    Data Server       (hroot) : ", btd.hroot, '\n',
	)
    
end