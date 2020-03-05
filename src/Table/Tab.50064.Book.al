table 50064 Book
{
    Caption = 'Book';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if Code = '' then
                    exit;
                if StrLen(Code) <= 3 then
                    Error('Code must have minimum 4 character');
            end;
        }
        field(21; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }


    trigger OnInsert()
    begin

    end;

}
