# install optechx.DownloadFile.dll (odf)
dotnet restore C:\Projects\optechx.DownloadFile\optechx.DownloadFile\optechx.DownloadFile.csproj
msbuild C:\Projects\optechx.DownloadFile\optechx.DownloadFile.sln /verbosity:minimal /logger:"C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll" /property:Configuration=Release
New-Item -Path C:\odf -ItemType Directory -Confirm:$false -Force
Copy-Item -Path C:\Projects\optechx.DownloadFile\optechx.DownloadFile\bin\Release\netcoreapp2.2\* -Destination C:\odf\ -Recurse -Confirm:$false -Force