haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl -res "assets" -out "assets" -check-ogg -exclude-names "ngapi.txt,Logo_Animation.webm" -exclude-path "preloader,fonts,ui,trophy,misc"
haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl -res "assets/preloader" -out "preloader"
:: haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
:: hl hxd.fmt.pak.Build.hl -res "assets/api" -out "ngapi" -diff
copy assets.pak C:\Users\Nick\Documents\Projects\Haxe\SubspaceEmissaryCollab\export\js
:: copy ngapi.pak C:\Users\Nick\Documents\Projects\Haxe\SubspaceEmissaryCollab\export\js
copy preloader.pak C:\Users\Nick\Documents\Projects\Haxe\SubspaceEmissaryCollab\export\js