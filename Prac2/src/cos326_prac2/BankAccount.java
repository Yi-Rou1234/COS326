package cos326_prac2;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import java.util.List;

@Entity
public class BankAccount {
    @Id
    private Long accountNumber;
    private String accountHolderName;

    @OneToMany(mappedBy = "bankAccount")
    private List<Transaction> transactions;

    // Getters and setters
    public Long getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(Long accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getAccountHolderName() {
        return accountHolderName;
    }

    public void setAccountHolderName(String accountHolderName) {
        this.accountHolderName = accountHolderName;
    }

    public List<Transaction> getTransactions() {
        return transactions;
    }

    public void setTransactions(List<Transaction> transactions) {
        this.transactions = transactions;
    }

    // Method to get a specific transaction ID (you could modify this to suit your needs)
    public Long getTransactionId(Long transactionId) {
        for (Transaction transaction : transactions) {
            if (transaction.getTransactionId().equals(transactionId)) {
                return transaction.getTransactionId();
            }
        }
        return null; // Return null if transaction not found
    }
}
