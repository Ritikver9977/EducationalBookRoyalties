

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationalBookRoyalties {
    address public owner;

    struct Book {
        uint256 id;
        string title;
        address payable author;
        uint256 price;
        uint256 royaltyPercentage; // Royalty percentage (e.g., 5 for 5%)
    }

    mapping(uint256 => Book) public books;
    mapping(uint256 => uint256) public bookSales; // Total sales for each book
    uint256 public bookCounter;

    event BookAdded(uint256 id, string title, address author, uint256 price, uint256 royaltyPercentage);
    event BookPurchased(uint256 bookId, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addBook(string memory title, uint256 price, uint256 royaltyPercentage) public {
        require(price > 0, "Price must be greater than zero");
        require(royaltyPercentage >= 0 && royaltyPercentage <= 100, "Royalty must be between 0 and 100");

        bookCounter++;
        books[bookCounter] = Book({
            id: bookCounter,
            title: title,
            author: payable(msg.sender),
            price: price,
            royaltyPercentage: royaltyPercentage
        });

        emit BookAdded(bookCounter, title, msg.sender, price, royaltyPercentage);
    }

    function purchaseBook(uint256 bookId) public payable {
        Book memory book = books[bookId];
        require(book.id != 0, "Book does not exist");
        require(msg.value == book.price, "Incorrect payment amount");

        uint256 royalty = (msg.value * book.royaltyPercentage) / 100;
        book.author.transfer(royalty);
        payable(owner).transfer(msg.value - royalty);

        bookSales[bookId]++;

        emit BookPurchased(bookId, msg.sender);
    }

    function getBookSales(uint256 bookId) public view returns (uint256) {
        return bookSales[bookId];
    }
}
