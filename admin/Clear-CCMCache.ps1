function Clear-CCMCache {
    "Clearing CCM Cache folders ..."
    [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
    $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
    ForEach ($CacheItem in $CacheInfo) {
        $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
    }
}

Clear-CCMCache
