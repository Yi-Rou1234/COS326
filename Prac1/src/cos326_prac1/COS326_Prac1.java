package cos326_prac1;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.persistence.*;

public class COS326_Prac1 extends JFrame {
    private JTextField transactionIdField, dateField, amountField, senderField, receiverField;
    private JTextArea messageArea;
    private JComboBox<String> typeField;
    private EntityManagerFactory emf;
    private EntityManager em;

    public COS326_Prac1() {
        // Initialize EntityManagerFactory and EntityManager
        emf = Persistence.createEntityManagerFactory("$objectdb/db/prac1.odb");
        em = emf.createEntityManager();

        setTitle("Transaction Manager");
        setSize(1200, 600);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new GridLayout(10, 2));

        add(new JLabel("Transaction ID:"));
        transactionIdField = new JTextField();
        add(transactionIdField);

        add(new JLabel("Transaction Date (yyyy-MM-dd):"));
        dateField = new JTextField();
        add(dateField);

        add(new JLabel("Transaction Amount:"));
        amountField = new JTextField();
        add(amountField);

        add(new JLabel("Sender Account Number:"));
        senderField = new JTextField();
        add(senderField);

        add(new JLabel("Receiver Account Number:"));
        receiverField = new JTextField();
        add(receiverField);

        add(new JLabel("Transaction Type:"));
        String[] transactionTypes = {"Deposit", "Withdrawal", "Transfer"};
        typeField = new JComboBox<>(transactionTypes);
        add(typeField);

        JButton saveButton = new JButton("Save");
        saveButton.addActionListener(new SaveButtonListener());
        add(saveButton);

        JButton searchButton = new JButton("Search");
        searchButton.addActionListener(new SearchButtonListener());
        add(searchButton);

        JButton updateButton = new JButton("Update");
        updateButton.addActionListener(new UpdateButtonListener());
        add(updateButton);

        JButton deleteButton = new JButton("Delete");
        deleteButton.addActionListener(new DeleteButtonListener());
        add(deleteButton);

        JButton calculateButton = new JButton("Calculate Total");
        calculateButton.addActionListener(new CalculateButtonListener());
        add(calculateButton);

        JButton showAllButton = new JButton("Show All Transactions");
        showAllButton.addActionListener(new ShowAllButtonListener());
        add(showAllButton);

        messageArea = new JTextArea();
        messageArea.setEditable(false);
        add(new JScrollPane(messageArea), BorderLayout.CENTER);

        setVisible(true);
    }

    private class SaveButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                em.getTransaction().begin();
                Date transactionDate = new SimpleDateFormat("yyyy-MM-dd").parse(dateField.getText());
                Transactions transaction = new Transactions(
                        transactionDate,
                        Double.parseDouble(amountField.getText()),
                        senderField.getText(),
                        receiverField.getText(),
                        (String) typeField.getSelectedItem()
                );
                em.persist(transaction);
                em.getTransaction().commit();
                displayAllTransactions();
                messageArea.append("Transaction saved successfully!\n");
            } catch (ParseException ex) {
                messageArea.setText("Error parsing date: " + ex.getMessage());
            } catch (Exception ex) {
                messageArea.setText("Error saving transaction: " + ex.getMessage());
            }
        }
    }

    private class SearchButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                Long id = Long.parseLong(transactionIdField.getText());
                Transactions transaction = em.find(Transactions.class, id);
                if (transaction != null) {
                    dateField.setText(new SimpleDateFormat("yyyy-MM-dd").format(transaction.getTransactionDate()));
                    amountField.setText(String.valueOf(transaction.getAmount()));
                    senderField.setText(transaction.getSenderAccountNumber());
                    receiverField.setText(transaction.getReceiverAccountNumber());
                    typeField.setToolTipText((String) typeField.getSelectedItem());
                    messageArea.setText("Transaction found!");
                } else {
                    messageArea.setText("Transaction not found!");
                }
            } catch (Exception ex) {
                messageArea.setText("Error searching transaction: " + ex.getMessage());
            }
        }
    }

    private class UpdateButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                em.getTransaction().begin();
                Long id = Long.parseLong(transactionIdField.getText());
                Transactions transaction = em.find(Transactions.class, id);
                if (transaction != null) {
                    transaction.setTransactionDate(new SimpleDateFormat("yyyy-MM-dd").parse(dateField.getText()));
                    transaction.setAmount(Double.parseDouble(amountField.getText()));
                    transaction.setSenderAccountNumber(senderField.getText());
                    transaction.setReceiverAccountNumber(receiverField.getText());
                    transaction.setTransactionType((String) typeField.getSelectedItem());
                    em.getTransaction().commit();
                    messageArea.setText("Transaction updated successfully!");
                } else {
                    messageArea.setText("Transaction not found!");
                }
            } catch (ParseException ex) {
                messageArea.setText("Error parsing date: " + ex.getMessage());
            } catch (Exception ex) {
                messageArea.setText("Error updating transaction: " + ex.getMessage());
            }
        }
    }

    private class DeleteButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                em.getTransaction().begin();
                Long id = Long.parseLong(transactionIdField.getText());
                Transactions transaction = em.find(Transactions.class, id);
                if (transaction != null) {
                    em.remove(transaction);
                    em.getTransaction().commit();
                    messageArea.setText("Transaction deleted successfully!");
                } else {
                    messageArea.setText("Transaction not found!");
                }
            } catch (Exception ex) {
                messageArea.setText("Error deleting transaction: " + ex.getMessage());
            }
        }
    }

    private class CalculateButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            try {
                Query query = em.createQuery("SELECT SUM(t.amount) FROM Transactions t");
                Double total = (Double) query.getSingleResult();
                messageArea.setText("Total amount of all transactions: " + total);
            } catch (Exception ex) {
                messageArea.setText("Error calculating total: " + ex.getMessage());
            }
        }
    }

    private class ShowAllButtonListener implements ActionListener {
        public void actionPerformed(ActionEvent e) {
            displayAllTransactions();
        }
    }

    private void displayAllTransactions() {
        try {
            TypedQuery<Transactions> query = em.createQuery("SELECT t FROM Transactions t", Transactions.class);
            List<Transactions> results = query.getResultList();
            StringBuilder sb = new StringBuilder();
            for (Transactions t : results) {
                sb.append(t).append("\n");
            }
            messageArea.setText(sb.toString());
        } catch (Exception ex) {
            messageArea.setText("Error displaying transactions: " + ex.getMessage());
        }
    }

    public static void main(String[] args) {
        new COS326_Prac1();
    }
}
