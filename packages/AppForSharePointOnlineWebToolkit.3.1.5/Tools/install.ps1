param($installPath, $toolsPath, $package, $project)

Import-Module (Join-Path $toolsPath common.psm1) -Force

try {

    # Indicates if the current project is a VB project
    $IsVbProject = ($project.CodeModel.Language -eq [EnvDTE.CodeModelLanguageConstants]::vsCMLanguageVB)

    # Indicates if the current project is an MVC project
    $IsMvcProject = ($project.Object.References | Where-Object { $_.Identity -eq "System.Web.Mvc" }) -ne $null

    # The filters folder.
    $FiltersProjectItem = $project.ProjectItems.Item("Filters");

    if ($IsVbProject) {
        # For VB project, delete TokenHelper.cs, SharePointContext.cs and SharePointContextFilterAttribute.cs
        $project.ProjectItems | Where-Object { ($_.Name -eq "TokenHelper.cs") -or ($_.Name -eq "SharePointContext.cs") } | ForEach-Object { $_.Delete() }
        $FiltersProjectItem.ProjectItems | Where-Object { ($_.Name -eq "SharePointContextFilterAttribute.cs") } | ForEach-Object { $_.Delete() }

        # Delete SharePointContextFilterAttribute.vb if the web project is not MVC.
        if (!$IsMvcProject) {
            $FiltersProjectItem.ProjectItems | Where-Object { $_.Name -eq "SharePointContextFilterAttribute.vb" } | ForEach-Object { $_.Delete() }
        }

        # Add Imports for VB project
        $VbImports | ForEach-Object {
            if (!($project.Object.Imports -contains $_)) {
                $project.Object.Imports.Add($_)
            }
        }
    }
    else {
        # For CSharp project, delete TokenHelper.vb, SharePointContext.vb and SharePointContextFilterAttribute.vb
        $project.ProjectItems | Where-Object { ($_.Name -eq "TokenHelper.vb") -or ($_.Name -eq "SharePointContext.vb") } | ForEach-Object { $_.Delete() }
        $FiltersProjectItem.ProjectItems | Where-Object { ($_.Name -eq "SharePointContextFilterAttribute.vb") } | ForEach-Object { $_.Delete() }

        # Delete SharePointContextFilterAttribute.cs if the web project is not MVC.
        if (!$IsMvcProject) {
            $FiltersProjectItem.ProjectItems | Where-Object { $_.Name -eq "SharePointContextFilterAttribute.cs" } | ForEach-Object { $_.Delete() }
        }
    }
    
    # Delete the Filters folder if there is no item in it.
    if ($FiltersProjectItem.ProjectItems.Count -eq 0) {
        try {
            $FiltersProjectItem.Delete()
        }
        catch {
            Write-Host "Error while deleting the Filters folder: " + $_.Exception -ForegroundColor Yellow
        }
    }

    # Set CopyLocal = True as needed
    Foreach ($spRef in $CopyLocalReferences) {
        $project.Object.References | Where-Object { $_.Identity -eq $spRef } | ForEach-Object { $_.CopyLocal = $True }
    }

} catch {

    Write-Host "Error while installing package: " + $_.Exception -ForegroundColor Red
    exit
}
# SIG # Begin signature block
# MIIiMwYJKoZIhvcNAQcCoIIiJDCCIiACAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBQfEY+NGRkMyCV
# ClOJCX1xVSqPM9I7jehM9+Wmk6pRw6CCC4IwggUKMIID8qADAgECAhMzAAABTjzx
# c/TdU1KlAAAAAAFOMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMTYxMTE3MjE1OTEzWhcNMTgwMjE3MjE1OTEzWjCBgjEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoGA1UECxMDQU9D
# MR4wHAYDVQQDExVNaWNyb3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQC58xaRUfuTb7e5retoql6bh8UQIHbL7NTInOp1aKla
# gTVPjiHpEjqAiZ1vCfp5P2K/x7kAeQFzLwrzZznob1YPXaJu1UwZnB2sxQ4IFw88
# KsIkp6571Flb20zfJEZ0RH/w928jQh69E5f8InQbBBtUYxBcamMkXYk6TpVob5q8
# G9o81Tgy1Z9inFjIa4dBbSLOP6la//B2ot2T6JjkYlFd1M39J9x3wpKzBPw6IN7B
# tB5M6cgn8p4tz2kPo8W/o6K1mfmegp6S2kl0wIRyYD6wqAXd44XDEE67D7Z8tGLd
# 4wxctGnDIRovv8AwRgXFH+7KPsTe7bGWhmZV2E3t8kV/AgMBAAGjggF6MIIBdjAf
# BgNVHSUEGDAWBgorBgEEAYI3PQYBBggrBgEFBQcDAzAdBgNVHQ4EFgQUJjQeyo/y
# dAqO4lMtLxMqMxdTW4QwUQYDVR0RBEowSKRGMEQxDDAKBgNVBAsTA0FPQzE0MDIG
# A1UEBRMrMjMwODY1K2I0YjEyODc4LWUyOTMtNDNlOS1iMjFlLTdkMzA3MTlkNDUy
# ZjAfBgNVHSMEGDAWgBTm/F97uyIAWORyTrX0IXQjMubvrDBWBgNVHR8ETzBNMEug
# SaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
# aWNDb2RTaWdQQ0FfMjAxMC0wNy0wNi5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsG
# AQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY0Nv
# ZFNpZ1BDQV8yMDEwLTA3LTA2LmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEB
# CwUAA4IBAQC9+Q5if4CpT6WHVNhhFj5CJv/i5cm/rFPoaBbnfRyg+AOi9iDtGq5c
# IN8UpX4XJP4ehzWEDoSsklYHQVOirfX8FVVGWCj4qj9swAh3nnP7nk7cWhmsCbK7
# 91CBDH71Rcj9NKkXpJpSkbcQ5QZyuu0YPGsAlrJw4sjewz738q7T2E8b4d1JCIN/
# S5zAqdmH45xPTwQJt/IxPgWdgWu43mlYCnNWhLZh+X4Tc9GFWmwxXJlEL89jbXQV
# F16qIpqC7hCBSYxa8vGUYvi7JIslKt8lVg17QOnDI06ti58ydAOUC22AygTJOR80
# ryuTlWvb/37N5+uLADMMDHVobyZ5G2WuMIIGcDCCBFigAwIBAgIKYQxSTAAAAAAA
# AzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0
# aG9yaXR5IDIwMTAwHhcNMTAwNzA2MjA0MDE3WhcNMjUwNzA2MjA1MDE3WjB+MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNy
# b3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEA6Q5kUHlntcTj/QkATJ6UrPdWaOpE2M/FWE+ppXZ8bUW60zmS
# tKQe+fllguQX0o/9RJwI6GWTzixVhL99COMuK6hBKxi3oktuSUxrFQfe0dLCiR5x
# lM21f0u0rwjYzIjWaxeUOpPOJj/s5v40mFfVHV1J9rIqLtWFu1k/+JC0K4N0yiuz
# O0bj8EZJwRdmVMkcvR3EVWJXcvhnuSUgNN5dpqWVXqsogM3Vsp7lA7Vj07IUyMHI
# iiYKWX8H7P8O7YASNUwSpr5SW/Wm2uCLC0h31oVH1RC5xuiq7otqLQVcYMa0Kluc
# IxxfReMaFB5vN8sZM4BqiU2jamZjeJPVMM+VHwIDAQABo4IB4zCCAd8wEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFOb8X3u7IgBY5HJOtfQhdCMy5u+sMBkGCSsG
# AQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTAD
# AQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0w
# S6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYI
# KwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWlj
# Um9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0MIGdBgNVHSAEgZUwgZIwgY8GCSsGAQQB
# gjcuAzCBgTA9BggrBgEFBQcCARYxaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BL
# SS9kb2NzL0NQUy9kZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBh
# AGwAXwBQAG8AbABpAGMAeQBfAFMAdABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG
# 9w0BAQsFAAOCAgEAGnTvV08pe8QWhXi4UNMi/AmdrIKX+DT/KiyXlRLl5L/Pv5PI
# 4zSp24G43B4AvtI1b6/lf3mVd+UC1PHr2M1OHhthosJaIxrwjKhiUUVnCOM/PB6T
# +DCFF8g5QKbXDrMhKeWloWmMIpPMdJjnoUdD8lOswA8waX/+0iUgbW9h098H1dly
# ACxphnY9UdumOUjJN2FtB91TGcun1mHCv+KDqw/ga5uV1n0oUbCJSlGkmmzItx9K
# Gg5pqdfcwX7RSXCqtq27ckdjF/qm1qKmhuyoEESbY7ayaYkGx0aGehg/6MUdIdV7
# +QIjLcVBy78dTMgW77Gcf/wiS0mKbhXjpn92W9FTeZGFndXS2z1zNfM8rlSyUkdq
# wKoTldKOEdqZZ14yjPs3hdHcdYWch8ZaV4XCv90Nj4ybLeu07s8n07VeafqkFgQB
# pyRnc89NT7beBVaXevfpUk30dwVPhcbYC/GO7UIJ0Q124yNWeCImNr7KsYxuqh3k
# hdpHM2KPpMmRM19xHkCvmGXJIuhCISWKHC1g2TeJQYkqFg/XYTyUaGBS79ZHmaCA
# QO4VgXc+nOBTGBpQHTiVmx5mMxMnORd4hzbOTsNfsvU9R1O24OXbC2E9KteSLM43
# Wj5AQjGkHxAIwlacvyRdUQKdannSF9PawZSOB3slcUSrBmrm1MbfI5qWdcUxghYH
# MIIWAwIBATCBlTB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSgwJgYDVQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDEwAhMzAAAB
# Tjzxc/TdU1KlAAAAAAFOMA0GCWCGSAFlAwQCAQUAoIH5MBkGCSqGSIb3DQEJAzEM
# BgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMC8GCSqG
# SIb3DQEJBDEiBCANwjEq1mRTLjiB9lGhOZByCZ7CKpBEPKHzjbvFOiDJkTCBjAYK
# KwYBBAGCNwIBDDF+MHygYoBgAGkAbgBzAHQAYQBsAGwAXwBiADEAMwAxADEAYwA1
# ADcALQA3ADEAYQBmAC0ANAA1AGYAYwAtADkAZgBmADkALQA3AGMAYQBjADkAMABj
# ADcAOAA2ADYANgAuAHAAcwAxoRaAFGh0dHA6Ly9taWNyb3NvZnQuY29tMA0GCSqG
# SIb3DQEBAQUABIIBAJ3hVB3aluPzr8LjVAcgi3Zbs+9hg3dFJzEF7rKuLq+/z2oD
# 8MIsFGaZcsK/mke52YWCEM8mAw+ptohxVLW1ziWV4y/fCEjzyUSWwWs2yaEICC6b
# gmrZ4rxA4e7o1hwBtDSkBmETGFyEPj6bqR5nSC5ioqeP3TQUyL5UDCe5TRLBCaSM
# aCoXPtASs8+C/5wPDwLpMSKA5aYrgzOYPJ2YNRrRORxU7hLXjvpElxIQtFudMZZF
# a6/1DIwYwmvnIAm2bN1FQIa2TDrUZ06WhIt3qBj1A8ISRbzuFrJudMgh89+1+wou
# qVopOLgYS2FN0SMCD/cGm+pKHXYpeHY7fE4SpgOhghNGMIITQgYKKwYBBAGCNwMD
# ATGCEzIwghMuBgkqhkiG9w0BBwKgghMfMIITGwIBAzEPMA0GCWCGSAFlAwQCAQUA
# MIIBPAYLKoZIhvcNAQkQAQSgggErBIIBJzCCASMCAQEGCisGAQQBhFkKAwEwMTAN
# BglghkgBZQMEAgEFAAQgKo+QgXsi0oVUSLsf7McxOmDpVfeVvEkld/ujODbiQSMC
# BlnWh4cxfxgTMjAxNzEwMDYwMDA2MTUuNjExWjAHAgEBgAIB9KCBuKSBtTCBsjEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEMMAoGA1UECxMDQU9D
# MScwJQYDVQQLEx5uQ2lwaGVyIERTRSBFU046MTJFNy0zMDY0LTYxMTIxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wggg7KMIIGcTCCBFmgAwIB
# AgIKYQmBKgAAAAAAAjANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzAR
# BgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
# Y3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2Vy
# dGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAx
# MjE0NjU1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYw
# JAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAKkdDbx3EYo6IOz8E5f1+n9plGt0VBDVpQoA
# goX77XxoSyxfxcPlYcJ2tz5mK1vwFVMnBDEfQRsalR3OCROOfGEwWbEwRA/xYIiE
# VEMM1024OAizQt2TrNZzMFcmgqNFDdDq9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+B
# VLHPk0ySwcSmXdFhE24oxhr5hoC732H8RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3w
# V3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v0Ev9buWayrGo8noqCjHw2k4GkbaICDXo
# eByw6ZnNPOcvRLqn9NxkvaQBwSAJk3jN/LzAyURdXhacAQVPIk0CAwEAAaOCAeYw
# ggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTVYzpcijGQ80N7fEYbxTNo
# WoVtVTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBW
# BgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUH
# AQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtp
# L2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBoAYDVR0gAQH/BIGV
# MIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIw
# NB4yIB0ATABlAGcAYQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4A
# dAAuIB0wDQYJKoZIhvcNAQELBQADggIBAAfmiFEN4sbgmD+BcQM9naOhIW+z66bM
# 9TG+zwXiqf76V20ZMLPCxWbJat/15/B4vceoniXj+bzta1RXCCtRgkQS+7lTjMz0
# YBKKdsxAQEGb3FwX/1z5Xhc1mCRWS3TvQhDIr79/xn/yN31aPxzymXlKkVIArzgP
# F/UveYFl2am1a+THzvbKegBvSzBEJCI8z+0DpZaPWSm8tv0E4XCfMkon/VWvL/62
# 5Y4zu2JfmttXQOnxzplmkIz/amJ/3cVKC5Em4jnsGUpxY517IW3DnKOiPPp/fZZq
# kHimbdLhnPkd/DjYlPTGpQqWhqS9nhquBEKDuLWAmyI4ILUl5WTs9/S/fmNZJQ96
# LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF0M2n0O99g/DhO3EJ3110mCIIYdqwUB5v
# vfHhAN/nMQekkzr3ZUd46PioSKv33nJ+YWtvd6mBy6cJrDm77MbL2IK0cs0d9LiF
# AR6A+xuJKlQ5slvayA1VmXqHczsI5pgt6o3gMy4SKfXAL1QnIffIrE7aKLixqduW
# sqdCosnPGUFN4Ib5KpqjEWYw07t0MkvfY3v1mYovG8chr1m1rtxEPJdQcdeh0sVV
# 42neV8HR3jDA/czmTfsNv11P6Z0eGTgvvM9YBS7vDaBQNdrvCScc1bN+NR4Iuto2
# 29Nfj950iEkSMIIE2TCCA8GgAwIBAgITMwAAAKyKIbx60pty9AAAAAAArDANBgkq
# hkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQ
# MA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9u
# MSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0xNjA5
# MDcxNzU2NTRaFw0xODA5MDcxNzU2NTRaMIGyMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMQwwCgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIg
# RFNFIEVTTjoxMkU3LTMwNjQtNjExMjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKHE
# 9DyljnMxoRdBXKt3CLep0UOqu9/cdPm6NVZqhAnYqbv7VPcY2cals0Po+iYBzD01
# 9X4L5EyYKtOGlSUFXN67Ow0vYuyP2Yx0rzeLF5trN6dKsDStcsiJ9YHModU/qPOx
# Baj3pwe6QdmojzFGne1iK+Bqm3ksuuf1GbYmf4TSHaUoM7Dmwi15mKuI4w8fZnua
# 2BhebIHxOGB0Hjqnp+s0alxevXWlrVWSV2XSJjqgEApBBLEnkGfg3u6LlaPnAOQN
# nMYCDqfWm0w9M8mEva6ixbzhiOdKn/ay41qneo6MoRheakbO9qyrmrKo/K9+p+Sw
# 580Fome1+kLx0gMkqucCAwEAAaOCARswggEXMB0GA1UdDgQWBBTYR3CohTWLE2Gv
# h5DoRRck4JinDTAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNV
# HR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9w
# cm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEE
# TjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMG
# A1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQBI7OheJ8MbGJxd
# tM52bjcMH11jHA1dpCPSFbTO0EAJ5ZtfrPF57XDtMl5dDHUh9PPUFYkB9WVrscDW
# jFrQuIX9R/qt9G8QSYaYev3BYRuvfGISuWVMUTZX+Z1gFITB2PvibxAsF4VjfsKP
# HhMV74AH8VCXLeS9+skoNphhNNdMAVgAqmLQBwNNwRJdlyyEn87xRmz1+vQGCs6b
# mHup5DUIk2YMxUSoSVC39wU7d3GqsAq/cW7+exPkaQAG768iJuDFfq02apxwghco
# AuC/vMMhpEABa1dX0vCeay0NRsinx0f+hJWbe0+cI+WsHf4Lby8+e8l1u0mL/I64
# RN36suf6oYIDdDCCAlwCAQEwgeKhgbikgbUwgbIxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xDDAKBgNVBAsTA0FPQzEnMCUGA1UECxMebkNpcGhl
# ciBEU0UgRVNOOjEyRTctMzA2NC02MTEyMSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVADlwJYsUyHndXwxd6Yuc
# s5SZ9xy3oIHBMIG+pIG7MIG4MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMQwwCgYDVQQLEwNBT0MxJzAlBgNVBAsTHm5DaXBoZXIgTlRTIEVTTjoy
# NjY1LTRDM0YtQzVERTErMCkGA1UEAxMiTWljcm9zb2Z0IFRpbWUgU291cmNlIE1h
# c3RlciBDbG9jazANBgkqhkiG9w0BAQUFAAIFAN2BP+8wIhgPMjAxNzEwMDUyMzM0
# MDdaGA8yMDE3MTAwNjIzMzQwN1owdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA3YE/
# 7wIBADAHAgEAAgIKrjAHAgEAAgIZUTAKAgUA3YKRbwIBADA2BgorBgEEAYRZCgQC
# MSgwJjAMBgorBgEEAYRZCgMBoAowCAIBAAIDFuNgoQowCAIBAAIDB6EgMA0GCSqG
# SIb3DQEBBQUAA4IBAQCEMgOp+ut+PfCOfJdwxRWkWaFXkPBtWF/bLf3H/JHFHRLc
# /wCXUGxWS77nFNpDkNugWjZpAs5c88XOu2iZ8g7V0eyKzK47tJ7FoEW5GW/xoxKC
# QACg90f2PXVze/n+c6MoT7+paKj4XXOW0eSrMiLIgjfVRmBcFBlhEv0Jyki/MYrz
# bJ6ztg3OsApVdptGB3qeWx59DWqs3ZR/mUwgyuR2l+/vej/14P8Z+gZ0YnhzozUk
# /z9+LVgtyUaywSYbPGhp7UHIz3KmzI+uzz0aIUsWIP2o5Ok5BywMP6noamIQc526
# KjY/EuxY4zAZVRzDxPrVFxsPwmyzW+v+tdmjtFuDMYIC9TCCAvECAQEwgZMwfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAACsiiG8etKbcvQAAAAAAKww
# DQYJYIZIAWUDBAIBBQCgggEyMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDAv
# BgkqhkiG9w0BCQQxIgQggVpQOmz+ea0pZ1qln8gsBfzS+o9d4kqJIuCns5vXtoQw
# geIGCyqGSIb3DQEJEAIMMYHSMIHPMIHMMIGxBBQ5cCWLFMh53V8MXemLnLOUmfcc
# tzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# JjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAArIoh
# vHrSm3L0AAAAAACsMBYEFJ1xEjZMjzSkDgpIwb6pZpUTowOxMA0GCSqGSIb3DQEB
# CwUABIIBAGx1SAor6uwfJD+cfL972XsdGTsJaa1MaRtQ0caIjDSQT4d+APZFl5Q/
# zXvX2m0H4F59j3jjd+Y7pEyyE41WfgvKjnZHG4WFaduFzW11QBKNII1aeNs0igBN
# KlawrP/j0FRDw4FEcBFxMJvDlW6BQu77uVntIt7Lky2OpGbEBNFyzAv7qrM7Gk79
# D/6MH4xe9af0uWl3xBYFp0GCAJZ+UVFoft9HRtQTJzsXD+h+eT474RUUTtHidGQ2
# IsxxmnWPS6NrmvMyYprU07bXaHPlp9zCSLv44pSvdVYF6LBD6pe7jwME3Npyr0sd
# pzl7Ki7x9bgYSbE6WIoF7DJZLYcVF5Y=
# SIG # End signature block