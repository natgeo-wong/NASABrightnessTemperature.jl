"""
    download(
        btd :: NASAPrecipitationDataset,
        geo :: GeoRegion = GeoRegion("GLB");
	    overwrite :: Bool = false
    ) -> nothing

Downloads a NASA Precipitation dataset specified by `btd` for a GeoRegion specified by `geo`

Arguments
=========
- `btd` : a `NASAPrecipitationDataset` specifying the dataset details and date download range
- `geo` : a `GeoRegion` (see [GeoRegions.jl](https://github.com/JuliaClimate/GeoRegions.jl)) that sets the geographic bounds of the data array in lon-lat

Keyword Arguments
=================
- `overwrite` : If `true`, overwrite any existing files
"""
function download(
	btd :: TbDataset{ST,DT},
	geo :: GeoRegion = GeoRegion("GLB");
	overwrite :: Bool = false
) where {ST<:AbstractString, DT<:TimeType}

	@info "$(modulelog()) - Downloading $(btd.name) data for the $(geo.name) GeoRegion from $(btd.start) to $(btd.stop)"

	lon,lat = btdlonlat(); nlon = length(lon)
	ginfo = RegionGrid(geo,lon,lat)

	@info "$(modulelog()) - Preallocating temporary arrays for extraction of $(btd.name) data for the $(geo.name) GeoRegion from the original gridded dataset"
	glon = ginfo.lon; nglon = length(glon); iglon = ginfo.ilon
	glat = ginfo.lat; nglat = length(glat); iglat = ginfo.ilat
	tmp0 = zeros(Float32,nglat,nglon)
	var  = zeros(Float32,nglon,nglat,48)

	if typeof(geo) <: PolyRegion
		  msk = ginfo.mask
	else; msk = ones(nglon,nglat)
	end

	if iglon[1] > iglon[end]
		shift = true
		iglon1 = iglon[1] : nlon; niglon1 = length(iglon1)
		iglon2 = 1 : iglon[end];  niglon2 = length(iglon2)
		tmp1 = @view tmp0[:,1:niglon1]
		tmp2 = @view tmp0[:,niglon1.+(1:niglon2)]
		@info "Temporary array sizes: $(size(tmp1)), $(size(tmp2))"
	else
		shift = false
		iglon = iglon[1] : iglon[end]
	end

	if iglat[1] > iglat[end]
		iglat = iglat[1] : -1 : iglat[end]
	else
		iglat = iglat[1] : iglat[end]
	end

	if btd.v6; varID = "precipitationCal"; else; varID = "precipitation" end

	for dt in btd.start : Day(1) : btd.stop

		fnc = btdfnc(btd,geo,dt)
		if overwrite || !isfile(fnc)

			@info "$(modulelog()) - Downloading $(btd.name) data for the $(geo.name) GeoRegion from the NASA Earthdata servers using OPeNDAP protocols for $(dt) ..."

			ymdfnc = Dates.format(dt,dateformat"yyyymmdd")
			btddir = joinpath(btd.hroot,"$(year(dt))",@sprintf("%03d",dayofyear(dt)))
			
			for it = 1 : 48

				@debug "$(modulelog()) - Loading data into temporary array for timestep $(dyfnc[it])"

				btdfnc = "$(btd.fpref).$ymdfnc-$(dyfnc[it]).$(btd.fsuff)"

				tryretrieve = 0
				ds = 0
				while !(typeof(ds) <: NCDataset) && (tryretrieve < 20)
					if tryretrieve > 0
						@info "$(modulelog()) - Attempting to request data from NASA OPeNDAP servers on Attempt $(tryretrieve+1) of 20"
					end
					ds = NCDataset(joinpath(btddir,btdfnc))
					tryretrieve += 1
				end
				
				if !shift
					NCDatasets.load!(ds[varID].var,tmp0,iglat,iglon,1)
				else
					NCDatasets.load!(ds[varID].var,tmp1,iglat,iglon1,1)
					NCDatasets.load!(ds[varID].var,tmp2,iglat,iglon2,1)
				end
				close(ds)

				@debug "$(modulelog()) - Extraction of data from temporary array for the $(geo.name) GeoRegion"
				for ilat = 1 : nglat, ilon = 1 : nglon
					varii = tmp0[ilat,ilon]
					mskii = msk[ilon,ilat]
					if (varii != -9999.9f0) && !isnan(mskii)
						var[ilon,ilat,it] = varii / 3600
					else; var[ilon,ilat,it] = NaN32
					end
				end
			end

			save(var,dt,btd,geo,ginfo)

		else

			@info "$(modulelog()) - $(btd.name) data for the $(geo.name) GeoRegion from the NASA Earthdata servers using OPeNDAP protocols for $(dt) exists in $(fnc), and we are not overwriting, skipping to next timestep ..."

		end

		flush(stderr)

	end

end