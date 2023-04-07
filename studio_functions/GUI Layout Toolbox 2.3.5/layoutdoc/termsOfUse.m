function termsOfUse
    if verLessThan('matlab','8.5')
        helpview([matlabroot,'/license.txt'])
    else
        helpview([matlabroot,'/license_agreement.txt'])
    end
end

