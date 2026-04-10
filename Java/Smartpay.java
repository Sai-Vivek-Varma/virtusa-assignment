import java.util.Scanner;

interface Billable {
    double calculateTotal(int units);
}

class Smartpay implements Billable {
    @Override
    public double calculateTotal(int units) {
        double tax = 0;

        if (units <= 100) {
            tax = units * 1;
        } else if (units <= 300) {
            tax = (100 * 1) + ((units - 100) * 2);
        } else {
            tax = (100 * 1) + (200 * 2) + ((units - 300) * 5);
        }

        return tax;
    }

    void printReceipt(String name, int prev, int curr) {
        if (prev > curr) {
            System.out.println("Previous reading > Current reading");
            return;
        }

        int units = curr - prev;
        double amount = calculateTotal(units);

        System.out.println("\n--- TGPDCL Electricity Bill ---\n");
        System.out.println("Customer Name : " + name);
        System.out.println("Units Consumed : " + units);
        System.out.println("Tax Amount : Rs. " + amount);
        System.out.println("Final Total : Rs. " + amount);
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

            try {
                System.out.print("Enter previous meter reading: ");
                int prev = Integer.parseInt(sc.nextLine());
                System.out.print("Enter current meter reading: ");
                int curr = Integer.parseInt(sc.nextLine());
                s.printReceipt(name, prev, curr);
            } catch (Exception e) {
                System.out.println("Invalid input. Please enter whole numbers for the meter readings.\n");
            }
        }

        sc.close();
    }
}
