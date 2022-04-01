function Set-JsonDataFile {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        <# JSON DATA STRUCTURE - DO NOT EDIT #>
        $d = [System.Collections.Specialized.OrderedDictionary]@{}
        $d.meta = [System.Collections.Specialized.OrderedDictionary]@{}
        $d.id = [System.Collections.Specialized.OrderedDictionary]@{}
        $d.installer = [System.Collections.Specialized.OrderedDictionary]@{}
        $d.uninstaller = [System.Collections.Specialized.OrderedDictionary]@{}
        $d.sysinfo = [System.Collections.Specialized.OrderedDictionary]@{}
    }
    
    process {
        <# NUSPEC PLACEHOLDER - DO NOT EDIT #>
        $d.meta.homepage = ""
        $d.meta.iconuri = ""
        $d.meta.copyright = ""
        $d.meta.license = ""
        $d.meta.docs = ""
        $d.meta.tags = ""
        $d.meta.summary = ""
        $d.meta.version = ""

        <# META EDITS - UPDATE AS REQUIRED #>

    }
    
    end {
        
    }
}



