page 50061 "Web Service Template"
{

    PageType = List;
    SourceTable = "Web Service Template";
    Caption = 'Web Service Templates';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                }
                field(Url; Url)
                {
                    ApplicationArea = All;
                }
                field("Capture File Exchange"; "Capture File Exchange")
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
            action("Initiate Web Call")
            {
                ApplicationArea = All;
                Image = TestFile;
                PromotedIsBig = true;
                Promoted = true;
                trigger OnAction()
                var
                    WebL: Codeunit "Web Management";
                begin
                    WebL.CreateItemCreationRequest();
                end;
            }
        }
    }

}
