page 50064 Book
{

    PageType = List;
    SourceTable = Book;
    Caption = 'Book';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "Book Card";

    layout
    {
        area(content)
        {
            repeater(General)
            {
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

}
