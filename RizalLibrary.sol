// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract RizalLibary {
    address internal librarian;

    enum Status { Available, Borrowed }
    Status constant defaultStatus = Status.Available;

    enum HoldOrder { Yes, No }
    HoldOrder constant defaultHoldOrder = HoldOrder.No;

    struct Student {
        uint idnumber;
        uint balance;
        HoldOrder holdorder;
    }

    struct Book {
        uint callnumber;
        Status status;
    }

    mapping(address => Student) public students;
    mapping(uint => Book) public books;
    mapping(address => uint) public borrowedBook;
    mapping(address => uint) public bookTimeStamp;

    modifier isLibrarian() {
        require(msg.sender == librarian, "You are not the Librarian!");
        _;
    }

    modifier isStudent() {
        require(msg.sender != librarian, "Librarians cannot perform this transaction!");
        _;
    }

    event StudentEnrolled(address indexed studentAddress, uint idnumber);

    constructor() {
        librarian = msg.sender;
    }
    
    function addStudent(address _student, uint _id) external isLibrarian {
        students[_student] = Student({
            idnumber: _id,
            balance: 0,
            holdorder: HoldOrder.No
        });

        emit StudentEnrolled(_student, _id);
    }

    function borrow(uint _callnumber) public isStudent{
        require(students[msg.sender].idnumber != 0, "Student not Enrolled");
        require(students[msg.sender].holdorder == HoldOrder.No, "You Have a HoldOrder");
        require(borrowedBook[msg.sender] == 0, "Already Borrowed A Book!");
        require(books[_callnumber].status == Status.Available, "Book is not Available");
        books[_callnumber].status = Status.Borrowed;
        borrowedBook[msg.sender] = _callnumber;
        bookTimeStamp[msg.sender] = block.timestamp;
    }

    function Return() external isStudent {
        require(students[msg.sender].idnumber != 0, "Student not enrolled.");
        require(borrowedBook[msg.sender] != 0, "No book to return.");

        uint borrowedCallNumber = borrowedBook[msg.sender];
        uint borrowedTime = bookTimeStamp[msg.sender];

        uint returnDeadline = 14 days;

        if (block.timestamp > borrowedTime + returnDeadline) {
            students[msg.sender].balance += 50000 wei;
            students[msg.sender].holdorder = HoldOrder.Yes;
        }

        books[borrowedCallNumber].status = Status.Available;

        borrowedBook[msg.sender] = 0;
        bookTimeStamp[msg.sender] = 0;
    }

    function payBalance() external payable isStudent {
        Student storage student = students[msg.sender];
        require(student.holdorder == HoldOrder.Yes, "No existing hold order.");
        require(msg.value >=  500000 wei, "Payment must be at least 500000 wei.");

        student.balance = 0;
        student.holdorder = HoldOrder.No;
    }
}