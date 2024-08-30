using NASABrightnessTemperature
using Documenter

DocMeta.setdocmeta!(NASABrightnessTemperature, :DocTestSetup, :(using NASABrightnessTemperature); recursive=true)

makedocs(;
    modules=[NASABrightnessTemperature],
    authors="Nathanael Wong <natgeo.wong@outlook.com>",
    sitename="NASABrightnessTemperature.jl",
    format=Documenter.HTML(;
        canonical="https://natgeo-wong.github.io/NASABrightnessTemperature.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/natgeo-wong/NASABrightnessTemperature.jl",
    devbranch="main",
)
