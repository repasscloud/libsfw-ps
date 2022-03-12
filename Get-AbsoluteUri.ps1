function Get-AbsoluteUri {
    [CmdletBinding()]
    param (
        [System.String]$Uri
    )
    begin {
        Add-Type -AssemblyName System.Web
        Add-Type -AssemblyName System.Net
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
    process {
        $WebRequestQuery = [System.Net.HttpWebRequest]::Create($Uri)
        $WebRequestQuery.Method = "HEAD"
        $ResponseValue = $WebRequestQuery.GetResponse()
        $ResponseUri = $ResponseValue.ResponseUri
        $AbsoluteUri = $ResponseUri.AbsoluteUri
        $ReturnValue = [System.Web.HttpUtility]::UrlDecode($AbsoluteUri)
        return $ReturnValue
    }
    end {
        [System.GC]::Collect()
    }
}