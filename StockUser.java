import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.PreparedStatement;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class StockUser
{
    // code taken from https://dev.mysql.com/doc/connector-j/8.0/en/connector-j-usagenotes-connect-drivermanager.html
    // 
    public static void main(String[] args) {
      Connection conn = null;
      Statement stmt = null;
      ResultSet rs = null;
      int numRows = -1;
      int userInput = -1;
      java.math.BigDecimal money;
      Scanner input = new Scanner(System.in);
      String accountName = "";
      String Query = "";

      try {
            conn =
                    DriverManager.getConnection(
                            "jdbc:mysql://localhost/StockMarket?" +
                            "user=student&password=password");

            // Do something with the Connection
            stmt = conn.createStatement();
           /* rs = stmt.executeQuery("SHOW TABLES;");
            if (rs!=null){
                while(rs.next())
                {
                    System.out.println(rs.getString(1));

                }
            }*/
            
            System.out.print("What is the name of your account? ");
            System.out.println();
            accountName = input.nextLine();
        
            while(userInput!=6)
            {
              System.out.print("Which operation would you like to perform (1-6)? ");
              System.out.println();
              userInput = input.nextInt();
             
              switch(userInput)
              {
                case 1: 
                  //System.out.println("your accountName: " + accountName);
                  //Query = "Select Balance from Person where AccountName = '" + accountName + "'";
                  Query = "Select Balance from Person";
                  rs = null;
                   rs = stmt.executeQuery(Query);
                  while(rs.next())
                  {
                    System.out.println(rs.getString(1));

                  }
                  break;
                    
                case 2: 
                  Query = "select CompanyName, sum(Quantity) as Amount "  +
                   "from Stock, Person, Company "  +
                  "where " +
                    "Person.AccountID = Stock.AccountID and " +
                    "Stock.CompanyID = Company.CompanyID and " +
                    "Person.AccountName = '" + accountName + "' " + 
                  "group by Stock.CompanyID";
                   rs = stmt.executeQuery(Query);
                  while(rs.next())
                  {
                    String cName = rs.getString("CompanyName");
                    String sum = rs.getString("Amount");
                    
                    System.out.println(cName + "\t" + sum);

                  }
                  break;
                case 3:
                  Query = "select LotID, Price, Quantity, Company.CompanyName " +
                  "from SellOrder, Stock, Company, Person " +
                  "where " +
                  "SellOrder.StockID = Stock.StockID and " +
                  "Stock.CompanyID = Company.CompanyID and " +
                  "Stock.AccountID = Person.AccountID "
                  ;
                  rs = stmt.executeQuery(Query);
                  /*while(rs.next())
                  {
                    String LotID = rs.getString("CompanyName");
                    String Price = rs.getString("Price");
                    String Q = rs.getString("Quantity");
                    String cName = rs.getString("CompanyName");
                    
                    System.out.println(LotID + "\t" + Price + "\t" + Q + "\t" +cName);
                  }*/
                  while(rs.next())
                  {
                    System.out.println(rs.getString(1) + "\t" + rs.getString(2) + "\t" + rs.getString(3) + "\t" + rs.getString(4));
                  }
                  break;
                case 4: 
                  System.out.print("please enter the amount to be deposited: ");
                  System.out.println();
                  money = input.nextBigDecimal();
                  CallableStatement Stmt = conn.prepareCall("{call DepositFunds(?, ?)}");
                  Stmt.setString(1, accountName);
                  Stmt.setBigDecimal(2, money);
                  rs = Stmt.executeQuery();
                  break;
                case 5:
                  System.out.print("please enter the amount to be withdrawn: ");
                  System.out.println();
                  money = input.nextBigDecimal();
                  Stmt = conn.prepareCall("{call WithDrawFunds(?, ?)}");
                  Stmt.setString(1, accountName);
                  Stmt.setBigDecimal(2, money);
                  rs = Stmt.executeQuery();
                  break;
                case 6: System.out.println("Goodbye."); break;
              }
            }

        } catch (SQLException ex) {
            // handle any errors
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        }
        finally {
            // it is a good idea to release
            // resources in a finally{} block
            // in reverse-order of their creation
            // if they are no-longer needed

            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException sqlEx) {
                } // ignore

                rs = null;
            }

            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException sqlEx) {
                } // ignore

                stmt = null;
            }
        }
   }
}

