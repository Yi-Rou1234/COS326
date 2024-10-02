package cos326_prac2;

import java.awt.BorderLayout;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import java.util.List;
import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class BankApp {
    private EntityManagerFactory emf;
    private EntityManager em;
    private JTextField accountNumberField, accountHolderNameField, transactionIdField, transactionDateField, amountField, senderAccountField, receiverAccountField, transactionTypeField;
    private JTextArea messageArea;

    public BankApp() {
        emf = Persistence.createEntityManagerFactory("$objectdb/db/prac2.odb");
        em = emf.createEntityManager();

        JFrame frame = new JFrame("Bank Application");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(1200, 600);

        JPanel panel = new JPanel();
        frame.add(panel, BorderLayout.WEST);

        placeComponents(panel);

        messageArea = new JTextArea();
        messageArea.setEditable(false);
        JScrollPane scrollPane = new JScrollPane(messageArea);
        frame.add(scrollPane, BorderLayout.CENTER);

        frame.setVisible(true);
    }

    private void placeComponents(JPanel panel) {
    GroupLayout layout = new GroupLayout(panel);
    panel.setLayout(layout);

    layout.setAutoCreateGaps(true);
    layout.setAutoCreateContainerGaps(true);

    JLabel accountNumberLabel = new JLabel("Account Number:");
    accountNumberField = new JTextField(20);

    JLabel accountHolderNameLabel = new JLabel("Account Holder Name:");
    accountHolderNameField = new JTextField(20);

    JLabel transactionIdLabel = new JLabel("Transaction ID:");
    transactionIdField = new JTextField(20);

    JLabel transactionDateLabel = new JLabel("Transaction Date:");
    transactionDateField = new JTextField(20);

    JLabel amountLabel = new JLabel("Amount:");
    amountField = new JTextField(20);

    JLabel senderAccountLabel = new JLabel("Sender Account:");
    senderAccountField = new JTextField(20);

    JLabel receiverAccountLabel = new JLabel("Receiver Account:");
    receiverAccountField = new JTextField(20);

    JLabel transactionTypeLabel = new JLabel("Transaction Type:");
    transactionTypeField = new JTextField(20);

    JButton saveButton = new JButton("Save");
    JButton deleteButton = new JButton("Delete");
    JButton calculateButton = new JButton("Calculate");
    JButton showAllButton = new JButton("Show All");

    saveButton.addActionListener(new SaveButtonListener());
    deleteButton.addActionListener(new DeleteButtonListener());
    calculateButton.addActionListener(new CalculateButtonListener());
    showAllButton.addActionListener(new ShowAllButtonListener());

    // Setup the layout
    GroupLayout.SequentialGroup hGroup = layout.createSequentialGroup();
    GroupLayout.ParallelGroup labelGroup = layout.createParallelGroup();
    GroupLayout.ParallelGroup fieldGroup = layout.createParallelGroup();
    
    // Add labels and fields
    labelGroup.addComponent(accountNumberLabel)
               .addComponent(accountHolderNameLabel)
               .addComponent(transactionIdLabel)
               .addComponent(transactionDateLabel)
               .addComponent(amountLabel)
               .addComponent(senderAccountLabel)
               .addComponent(receiverAccountLabel)
               .addComponent(transactionTypeLabel);

    fieldGroup.addComponent(accountNumberField)
               .addComponent(accountHolderNameField)
               .addComponent(transactionIdField)
               .addComponent(transactionDateField)
               .addComponent(amountField)
               .addComponent(senderAccountField)
               .addComponent(receiverAccountField)
               .addComponent(transactionTypeField);

    // Button group with spacing
    GroupLayout.SequentialGroup buttonGroup = layout.createSequentialGroup()
            .addComponent(saveButton)
            .addComponent(deleteButton)
            .addComponent(calculateButton)
            .addComponent(showAllButton);
    
    hGroup.addGroup(labelGroup)
          .addGroup(fieldGroup)
          .addGroup(buttonGroup);

    layout.setHorizontalGroup(hGroup);

    GroupLayout.SequentialGroup vGroup = layout.createSequentialGroup();
    vGroup.addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(accountNumberLabel)
                    .addComponent(accountNumberField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(accountHolderNameLabel)
                    .addComponent(accountHolderNameField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(transactionIdLabel)
                    .addComponent(transactionIdField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(transactionDateLabel)
                    .addComponent(transactionDateField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(amountLabel)
                    .addComponent(amountField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(senderAccountLabel)
                    .addComponent(senderAccountField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(receiverAccountLabel)
                    .addComponent(receiverAccountField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(transactionTypeLabel)
                    .addComponent(transactionTypeField))
           .addGroup(layout.createParallelGroup(GroupLayout.Alignment.BASELINE)
                    .addComponent(saveButton)
                    .addComponent(deleteButton)
                    .addComponent(calculateButton)
                    .addComponent(showAllButton));

    layout.setVerticalGroup(vGroup);
}


    private class SaveButtonListener implements ActionListener {
    @Override
    public void actionPerformed(ActionEvent e) {
        try {
            // Validate inputs
            if (accountNumberField.getText().trim().isEmpty() ||
                accountHolderNameField.getText().trim().isEmpty() ||
                transactionIdField.getText().trim().isEmpty() ||
                transactionDateField.getText().trim().isEmpty() ||
                amountField.getText().trim().isEmpty() ||
                senderAccountField.getText().trim().isEmpty() ||
                receiverAccountField.getText().trim().isEmpty() ||
                transactionTypeField.getText().trim().isEmpty()) {
                messageArea.setText("Error: All fields must be filled out.");
                return;
            }

            // Validate date format (YYYY-MM-DD)
            String dateFormat = "yyyy-MM-dd";
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(dateFormat);
            sdf.setLenient(false);
            try {
                sdf.parse(transactionDateField.getText());
            } catch (java.text.ParseException ex) {
                messageArea.setText("Error: Invalid date format. Please use " + dateFormat + ".");
                return;
            }

            // Parse other fields
            Long accountNumber = Long.parseLong(accountNumberField.getText());
            Long transactionId = Long.parseLong(transactionIdField.getText());
            Double amount = Double.parseDouble(amountField.getText());

            // Begin transaction
            em.getTransaction().begin();

            // Check if the account exists
            BankAccount account = em.find(BankAccount.class, accountNumber);
            if (account == null) {
                account = new BankAccount();
                account.setAccountNumber(accountNumber);
                account.setAccountHolderName(accountHolderNameField.getText());
                em.persist(account); // Persist the new account if it doesn’t exist
            }

            // Create and persist the transaction
            Transaction transaction = new Transaction();
            transaction.setTransactionId(transactionId);
            transaction.setTransactionDate(transactionDateField.getText());
            transaction.setAmount(amount);
            transaction.setSenderAccountNumber(senderAccountField.getText());
            transaction.setReceiverAccountNumber(receiverAccountField.getText());
            transaction.setTransactionType(transactionTypeField.getText());
            transaction.setBankAccount(account); // Associate the transaction with the account

            em.persist(transaction);
            em.getTransaction().commit();

            messageArea.setText("Transaction saved successfully!");
        } catch (NumberFormatException ex) {
            messageArea.setText("Error: Invalid number format. Please check your input.");
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
        } catch (Exception ex) {
            messageArea.setText("Error saving transaction: " + ex.getMessage());
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
        }
    }
}


    private class DeleteButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                em.getTransaction().begin();
                Long accountNumber = Long.parseLong(accountNumberField.getText());
                BankAccount account = em.find(BankAccount.class, accountNumber);
                if (account != null) {
                    Query query = em.createQuery("DELETE FROM Transaction t WHERE t.bankAccount = :account");
                    query.setParameter("account", account);
                    query.executeUpdate();
                    em.remove(account);
                    em.getTransaction().commit();
                    messageArea.setText("Account and transactions deleted successfully!");
                } else {
                    messageArea.setText("Account not found!");
                }
            } catch (Exception ex) {
                messageArea.setText("Error deleting account: " + ex.getMessage());
                if (em.getTransaction().isActive()) {
                    em.getTransaction().rollback();
                }
            }
        }
    }

    private class CalculateButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                Query query = em.createQuery("SELECT SUM(t.amount) FROM Transaction t");
                Double total = (Double) query.getSingleResult();
                messageArea.setText("Total amount of all transactions: " + total);
            } catch (Exception ex) {
                messageArea.setText("Error calculating total: " + ex.getMessage());
            }
        }
    }

    private class ShowAllButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                Long accountNumber = Long.parseLong(accountNumberField.getText());
                BankAccount account = em.find(BankAccount.class, accountNumber);

                if (account != null) {
                    Query query = em.createQuery("SELECT t FROM Transaction t WHERE t.bankAccount = :account");
                    query.setParameter("account", account);
                    List<Transaction> transactions = query.getResultList();

                    StringBuilder result = new StringBuilder("Account: " + account.getAccountNumber() + ", " + account.getAccountHolderName() + "\nTransactions:\n");
                    for (Transaction t : transactions) {
                        result.append("ID: ").append(t.getTransactionId())
                              .append(", Date: ").append(t.getTransactionDate())
                              .append(", Amount: ").append(t.getAmount())
                              .append(", Sender: ").append(t.getSenderAccountNumber())
                              .append(", Receiver: ").append(t.getReceiverAccountNumber())
                              .append(", Type: ").append(t.getTransactionType())
                              .append("\n");
                    }
                    messageArea.setText(result.toString());
                } else {
                    messageArea.setText("Account not found!");
                }
            } catch (Exception ex) {
                messageArea.setText("Error showing transactions: " + ex.getMessage());
            }
        }
    }

    public static void main(String[] args) {
        new BankApp();
    }
}
