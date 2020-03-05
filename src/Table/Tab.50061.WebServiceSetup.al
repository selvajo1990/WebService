table 50061 "Web Service Setup"
{
    Caption = 'Web Service Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(21; "Farfetch Item Creation"; Code[20])
        {
            Caption = 'Farfetch Item Creation';
            DataClassification = CustomerContent;
            TableRelation = "Web Service Template";
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}
