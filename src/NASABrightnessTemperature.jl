module NASABrightnessTemperature

## Modules Used
using Logging
using NetRC
using Printf
using Statistics

import Base: download, show, read

## Reexporting exported functions within these modules
using Reexport
@reexport using Dates
@reexport using GeoRegions
@reexport using NCDatasets

## Exporting the following functions:
export
        download, read, setup, extract, smoothing


modulelog() = "$(now()) - NASABrightnessTemperature.jl"

function __init__()
    setup()
end

## Including Relevant Files

include("setup.jl")

include("dataset.jl")
include("download.jl")
include("save.jl")
include("read.jl")
include("extract.jl")
include("smoothing.jl")
include("filesystem.jl")
include("backend.jl")
end
