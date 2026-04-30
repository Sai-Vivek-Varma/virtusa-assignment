import java.util.Scanner;

class InvalidReadingException extends Exception {
    public InvalidReadingException(String msg) {
        super(msg);
    }
}

class InvalidUnitException extends Exception {
    public InvalidUnitException(String msg) {
        super(msg);
    }
}

interface Billable {
    double calculateTotal(int units);
}

class Customer {
    String name;
    int prevReading, currReading;

    Customer(String name, int prev, int curr) {
        this.name = name;
        this.prevReading = prev;
        this.currReading = curr;
    }
}

class Smartpay implements Billable {

    public double calculateTotal(int units) {
        if (units <= 100)
            return units * 1;
        else if (units <= 300)
            return (100 * 1) + ((units - 100) * 2);
        return (100 * 1) + (200 * 2) + ((units - 300) * 5);
    }

    public int calculateUnits(int prev, int curr) throws InvalidReadingException {
        if (prev > curr) {
            throw new InvalidReadingException("Previous reading > Current reading");
        }
        return curr - prev;
    }

    void printReceipt(Customer c) throws InvalidReadingException {
        int units = calculateUnits(c.prevReading, c.currReading);
        double amount = calculateTotal(units);

        System.out.println("\n--- TGPDCL Electricity Bill ---\n");
        System.out.println("Customer Name : " + c.name);
        System.out.println("Units Consumed : " + units);
        System.out.printf("Bill Amount : ₹ %.2f\n", amount);
        System.out.println("\n--------------------------------\n");
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        Smartpay s = new Smartpay();

        while (true) {
            System.out.print("Enter Customer Name (type 'Exit' to quit): ");
            String name = sc.nextLine();

            if (name.equalsIgnoreCase("Exit")) {
                System.out.println("Closing app...");
                break;
            }

            while (true) {
                try {
                    System.out.print("Enter previous meter reading: ");
                    int prev = sc.nextInt();
                    sc.nextLine();
                    if (prev < 0)
                        throw new InvalidUnitException("Units cannot be negative.");

                    System.out.print("Enter current meter reading: ");
                    int curr = sc.nextInt();
                    sc.nextLine();
                    if (curr < 0)
                        throw new InvalidUnitException("Units cannot be negative.");

                    Customer c1 = new Customer(name, prev, curr);
                    s.printReceipt(c1);
                    break;

                } catch (InvalidReadingException | InvalidUnitException e) {
                    System.out.println("Error: " + e.getMessage());
                } catch (Exception e) {
                    System.out.println("Invalid input.");
                    sc.nextLine();
                }
            }
        }

        sc.close();
    }
}