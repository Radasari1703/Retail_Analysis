# Retail_Analysis
A pro-level End-to-end Retail Data Engineering: Transforming raw transaction data into business insights using SQL Server and Power BI.

```mermaid

graph TD;
    %% Define Styles
    classDef bronze fill:#e1d5e7,stroke:#9673a6,stroke-width:2px;
    classDef silver fill:#dae8fc,stroke:#6c8ebf,stroke-width:2px;
    classDef gold fill:#fff2cc,stroke:#d6b656,stroke-width:2px;
    classDef dash fill:#d5e8d4,stroke:#82b366,stroke-width:2px;

    %% Bronze Layer
    subgraph Bronze_Layer [Raw Data Ingestion]
        A[(Customer.csv)] -->|Bulk Insert| B[Raw_Staging_Customers]
        C[(Transactions.csv)] -->|Bulk Insert| D[Raw_Staging_Transactions]
        E[(Prod_Cat.csv)] -->|Bulk Insert| F[Raw_Staging_Prod_Cat]
    end

    %% Silver Layer
    subgraph Silver_Layer [Data Cleaning & Transformation]
        B -->|SQL Script 02| G[Customers Table]
        D -->|SQL Script 02| H[Transactions Table]
        F -->|SQL Script 02| I[Product_Categories Table]
    end

    %% Gold Layer
    subgraph Gold_Layer [Business Business KPIs]
        H -->|Join & Agg| J[v_Monthly_Sales_Trend]
        H -->|Join & Agg| K[v_Customer_Demographics]
        H -->|Join & Agg| L[v_Product_Performance]
    end

    %% Dashboard Layer
    subgraph User_Interface [Reporting]
        J --> M((Power BI Dashboard))
        K --> M
        L --> M
    end

    %% Apply Styles
    class B,D,F bronze;
    class G,H,I silver;
    class J,K,L gold;
    class M dash;
