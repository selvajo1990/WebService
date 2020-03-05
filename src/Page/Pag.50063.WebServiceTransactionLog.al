page 50063 "Web Service Transaction Log"
{

    PageType = List;
    SourceTable = "Web Service Transaction Log";
    Caption = 'Web Service Transaction Log';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No"; "Entry No")
                {
                    ApplicationArea = All;
                }
                field("Reply to Entry No."; "Reply to Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                }
                field(Direction; Direction)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
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
                field("Processed By"; "Processed By")
                {
                    ApplicationArea = All;
                }
                field("Has Error"; "Has Error")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                }
                field("Free Text 1"; "Free Text 1")
                {
                    ApplicationArea = All;
                }
                field("Free Text 2"; "Free Text 2")
                {
                    ApplicationArea = All;
                }
                field("Free Text 3"; "Free Text 3")
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
            action("Response Error Log")
            {
                ApplicationArea = All;
                Image = Log;
                PromotedIsBig = true;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Web Service Error Log";
                RunPageLink = "Transaction Entry No" = field("Entry No");
            }
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
