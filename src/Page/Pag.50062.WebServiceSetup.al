page 50062 "Web Service Setup"
{

    PageType = Card;
    SourceTable = "Web Service Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    Caption = 'Web Service Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Farfetch Item Creation"; "Farfetch Item Creation")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Get() then
            Insert();
    end;

}
