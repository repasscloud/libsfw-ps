function Get-AbsoluteUri {
    [CmdletBinding()]
    param (
        [System.String]$Uri
    )
    begin
    {
        Add-Type -AssemblyName System.Web
        Add-Type -AssemblyName System.Net
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    process
    {
        $ErrorActionPreference = "Stop"
        $WebRequestQuery = [System.Net.HttpWebRequest]::Create($Uri)
        $WebRequestQuery.Method = "HEAD"
        try {
            $ResponseValue = $WebRequestQuery.GetResponse()
            $ResponseUri = $ResponseValue.ResponseUri
            $FoundUri = $ResponseUri.AbsoluteUri
            $ReturnValue = [System.Web.HttpUtility]::UrlDecode($FoundUri)
            
        }
        catch {
            $ReturnValue = "INVALID"    
        }

        return $ReturnValue
    }
    end
    {
        $WebRequestQuery = [System.String]::Empty
        $ResponseValue = [System.String]::Empty
        $ResponseUri = [System.String]::Empty
        $FoundUri = [System.String]::Empty
        $ReturnValue = [System.String]::Empty
        [System.GC]::Collect()
    }
}