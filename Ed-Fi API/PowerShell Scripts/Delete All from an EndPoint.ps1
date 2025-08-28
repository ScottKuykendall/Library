# MIT License

# Copyright (c) 2025 Scott Kuykendall

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.



################################################################################################################################################################
# This script retrieves all of the records from a district's StudentEducationOrganizationResponsibilityAssociations and executes a DELETE against them
#
# Built for Ed-Fi version 6.2/Data Standard 4.x for year-specific ODS with endpoint StudentEducationOrganizationResponsibilityAssociations, but should work for any version/endpoint.
# ##############################################################################################################################################################
# WARNING: IF THE KEY/SECRET HAS PERMISSION (AND THERE ARE NO RELATIONAL CONSTRAINTS ALL RECORDS WILL BE DELETED for the LEA!####################################
################################################################################################################################################################



# Set OAuth 2.0 and API details
$clientId = "{clientKey}"
$clientSecret = "{clientSecret}"
$tokenUrl = "https://{baseEdFiURL}/oauth/token"     
$endpointURL = "https://{baseEdFiURL}/data/v3/2026/ed-fi/StudentEducationOrganizationResponsibilityAssociations"
$apiDistrict = "9"

# === STEP 1: Get Access Token ===
$authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${clientId}:$clientSecret"))

$tokenResponse = Invoke-RestMethod -Method Post -Uri ${tokenUrl} -Headers @{
    Authorization = $authHeader
    "Content-Type" = "application/x-www-form-urlencoded"
} -Body @{
    grant_type = "client_credentials"
    scope      = $scope
}

$accessToken = $tokenResponse.access_token
Write-Host "Access Token acquired: $accessToken"

# === STEP 2: GET Resources for District ===
$url = $endpointURL  + "?educationOrganizationId=$apiDistrict"

$getResponse = Invoke-RestMethod -Method Get -Uri $url -Headers @{
    Authorization = "Bearer $accessToken"
    "Accept"      = "application/json"
}
$recordCount = if ($getResponse) { $getResponse.Count } else { 0 }
Write-Host "Total records found for district : $recordCount"

# Iterate over each resource and delete
foreach ($resource in $getResponse) {
    Write-Host "--- Resource ---"
    Write-Host "delete: " + $resource.id
        if ($null -ne $resource.id) {
        $deleteUrl = "$endpointURL/$($resource.id)"
        Write-Host "Deleting resource ID: $($resource.id)"
        $deleteResponse = Invoke-RestMethod -Method Delete -Uri $deleteUrl -Headers @{
            Authorization = "Bearer $accessToken"
            "Accept"      = "application/json"
        }
        Write-Host "Delete response:"
        $deleteResponse | ConvertTo-Json -Depth 5 | Write-Host
    } else {
        Write-Host "No 'id' property found for this resource. Skipping delete."
    }

}

