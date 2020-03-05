table 50060 "Web Service Template"
{
    Caption = 'Web Service Template';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Template Code"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(21; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(22; "User ID"; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(23; Password; Text[50])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(24; Url; Text[250])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
        }
        field(25; "Capture File Exchange"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Template Code")
        {
            Clustered = true;
        }
    }

}
