
# E-Ticketing Database Interface - CPS510

A simple database interface for a hypothetical e-ticketing system filled with dummy values

## Group Members

Ali Asadpoor\
Sammy Peng\
Trixie Xu

## Instructions for Downloading and Configuring Oracle Instant Client and SQL*Plus on Linux

1. **Download the Oracle Instant Client:**

   ```bash
   wget https://download.oracle.com/otn_software/linux/instantclient/2360000/instantclient-basic-linux.x64-23.6.0.24.10.zip
   wget https://download.oracle.com/otn_software/linux/instantclient/2360000/instantclient-sqlplus-linux.x64-23.6.0.24.10.zip
   ```

2. **Extract the Downloaded Files:**
   Open a terminal and navigate to the directory where the downloaded files are located. Extract both `.zip` files:

   ```bash
   unzip instantclient-basic-linux.x64-23.6.0.24.10.zip
   unzip instantclient-sqlplus-linux.x64-23.6.0.24.10.zip
   ```

3. **Set Up Environment Variables:**
   - Navigate into the extracted `instantclient` directory:

     ```bash
     cd instantclient_23_6
     ```

   - Set the `LD_LIBRARY_PATH` environment variable to point to the directory:

     ```bash
     export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH
     ```

   - Set the `PATH` environment variable to include the directory:

     ```bash
     export PATH=$(pwd):$PATH
     ```

   - (Optional) Add these variables to your shell's configuration file (e.g., `~/.bashrc` or `~/.zshrc`) for persistent access:

     ```bash
     echo "export LD_LIBRARY_PATH=$(pwd):\$LD_LIBRARY_PATH" >> ~/.bashrc
     echo "export PATH=$(pwd):\$PATH" >> ~/.bashrc
     source ~/.bashrc
     ```

4. **Test SQL*Plus:**
   - Run SQL*Plus to confirm successful installation:

     ```bash
     sqlplus
     ```

   - If it opens successfully, the setup is complete.

## How to Interact with the Database

I'm getting tired of writing this, so I'll be quick. For the rest of this setup, just clone the repo, change the connection credentials, and then run the Python UI. Also, create a `db_config.env` file based on the provided template:

```bash
ORACLE_USER=your_username
ORACLE_PASS=your_password
ORACLE_CONN=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=oracle.cs.ryerson.ca)(Port=1521))(CONNECT_DATA=(SID=orcl)))
```