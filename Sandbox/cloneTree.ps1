param(
    [string] $source,
    [string] $target,
    [string] $filter
)


Copy-Item -path $source -Destination $target -Filter $filter -Recurse -Force 