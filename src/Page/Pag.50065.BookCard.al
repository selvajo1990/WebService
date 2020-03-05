page 50065 "Book Card"
{

    PageType = Card;
    SourceTable = Book;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Book Card';
    ODataKeyFields = Code;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(SystemId; Format(SystemId))
                {
                    ApplicationArea = All;
                }
                field(Code; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    [ServiceEnabled]
    procedure InsertBook(var actionContext: WebServiceActionContext)
    var
        BookL: Record Book;
    begin
        BookL.Init();
        BookL.Code := Rec.Code;
        BookL.Description := 'Action Bound';
        BookL.Insert(true);

        actionContext.SetObjectType(ObjectType::Page);
        actionContext.SetObjectId(Page::"Book Card");
        actionContext.AddEntityKey(Rec.FieldNo(Code), Rec.Code);
        actionContext.SetResultCode(WebServiceActionResultCode::Created);
    end;
}
