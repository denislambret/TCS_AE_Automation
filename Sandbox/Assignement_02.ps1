# Loop until we get a valid value for principal amount
# Note : if a value does not respect constraint then the try/catch block intercept the error and ask again for a valid value
while (-not $p) { 
    try {
            [validateRange(0,10000000)] $p = [float](Read-host "Enter principal amount")
    }
    catch {
            "Please enter a value between 0 and 10'000'000"
        }
}

# Loop until we get a valid value for rate of  interest amount
# Note : if a value does not respect constraint then the try/catch block intercept the error and ask again for a valid value
while (-not $r) { 
    try {
            [validateRange(0,1)] $r = [float](Read-host "Enter rate of interest (0 to 1)")
    }
    catch {
            "Please enter a real value between 0 and 1 "
        }
}

# Loop until we get a valid value for time
# Note : if a value does not respect constraint then the try/catch block intercept the error and ask again for a valid value
while (-not $t) { 
    try {
            [validateRange(1,100)] $t = [int](Read-host "Enter a period (1 to 100)"])}
    catch {
            "Please enter a value between 1 and 100"
        }
}

# Comnpute the SI
[float]$si = ($p * $r * $t) / 100

"p : " + $p
"r : " + $r
"t : " + $t
"SI : " + $si