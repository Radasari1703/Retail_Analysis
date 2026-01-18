#  Bronze Layer: Raw Data Ingestion

This folder serves as the landing zone (Bronze Layer) for the project. I’ve sourced these datasets to simulate a real-world retail environment where data arrives in raw CSV format. 

My goal here was to start with "unfiltered" data so I could personally handle the end-to-end engineering process—from initial ingestion to final business insights. 

### Why this data?
I chose these specific files because they represent a classic Relational Model:
* **Transactions:** My Fact table, containing all the high-volume sales and return records.
* **Customer & Product Info:** My Dimension tables, which I'll use to add context (demographics and categories) to the raw numbers.

By keeping the raw files here, I can ensure that my cleaning and transformation logic is fully reproducible from scratch.
