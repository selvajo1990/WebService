page 50060 "Web Service Error Log"
{

    PageType = List;
    SourceTable = "Web Service Error Log";
    Caption = 'Web Service Error Log';
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction Entry No"; "Transaction Entry No")
                {
                    ApplicationArea = All;
                }
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                }
                field("Entry Time"; "Entry Time")
                {
                    ApplicationArea = All;
                }
                field("Error Code"; "Error Code")
                {
                    ApplicationArea = All;
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("View Log File")
            {
                ApplicationArea = All;
                Image = XMLFile;
                PromotedIsBig = true;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    ExportTemplate();
                end;
            }
        }
    }

}
