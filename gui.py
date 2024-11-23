import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os

class DatabaseGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("E-Ticketing Database Interface")
        self.root.geometry("800x600")
        
        # Configure root window's grid
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        
        # Main container
        self.main_container = ttk.Frame(self.root, padding="10")
        self.main_container.grid(row=0, column=0, sticky="nsew")
        
        # Configure main container's grid
        self.main_container.columnconfigure(0, weight=1)
        self.main_container.rowconfigure(0, weight=0)  # For main menu
        self.main_container.rowconfigure(1, weight=1)  # For results section
        
        # Create main menu in top section
        self.create_main_menu()
        
        # Create results section in bottom section
        self.create_results_section()
        
    def create_main_menu(self):
        main_frame = ttk.Frame(self.main_container, padding="10")
        main_frame.grid(row=0, column=0, sticky="nsew")
        
        # Configure main frame's grid
        main_frame.columnconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
        ttk.Label(main_frame, text="E-Ticketing Database Management", font=('Helvetica', 16)).grid(row=0, column=0, columnspan=2, pady=20)
        
        buttons = [
            ("Drop Tables", self.drop_tables),
            ("Create Tables", self.create_tables),
            ("Populate Tables", self.populate_tables),
            ("Query Tables", self.query_tables),
            ("CRUD Operations", self.open_crud_window)
        ]
        
        for i, (text, command) in enumerate(buttons):
            row = (i // 2) + 1  # Start from row=1 since row=0 is the label
            col = i % 2
            ttk.Button(main_frame, text=text, command=command).grid(row=row, column=col, pady=10, padx=10, sticky="nsew")
    
    def create_results_section(self):
        results_frame = ttk.LabelFrame(self.main_container, text="Results", padding="10")
        results_frame.grid(row=1, column=0, sticky="nsew", pady=10)
        
        # Configure results frame's grid
        results_frame.columnconfigure(0, weight=1)
        results_frame.rowconfigure(0, weight=1)
        results_frame.rowconfigure(1, weight=0)
        
        # Create scrolled text widget
        self.results_text = scrolledtext.ScrolledText(results_frame)
        self.results_text.grid(row=0, column=0, sticky="nsew")
        
        # Add clear button
        ttk.Button(results_frame, text="Clear Results", command=self.clear_results).grid(row=1, column=0, pady=5, sticky='e')
    
    def clear_results(self):
        self.results_text.delete(1.0, tk.END)
    
    def execute_script(self, script_name):
        try:
            result = subprocess.run(['bash', script_name], 
                                 capture_output=True, 
                                 text=True,
                                 check=True)
            self.results_text.insert(tk.END, f"\n=== {script_name} executed successfully ===\n")
            self.results_text.insert(tk.END, result.stdout)
            self.results_text.see(tk.END)  # Auto-scroll to bottom
        except subprocess.CalledProcessError as e:
            self.results_text.insert(tk.END, f"\n=== Error executing {script_name} ===\n")
            self.results_text.insert(tk.END, e.stderr)
            self.results_text.see(tk.END)
    
    def drop_tables(self):
        self.execute_script("drop_tables.sh")
    
    def create_tables(self):
        self.execute_script("create_tables.sh")
    
    def populate_tables(self):
        self.execute_script("populate_tables.sh")
    
    def query_tables(self):
        self.execute_script("queries.sh")
    
    def open_crud_window(self):
        crud_window = tk.Toplevel(self.root)
        crud_window.title("CRUD Operations")
        crud_window.geometry("800x600")
        
        # Update the root window to get the current position
        self.root.update_idletasks()
        
        # Get the root window's position
        x = self.root.winfo_x()
        y = self.root.winfo_y()
        
        # Set the position of the Toplevel window to match the root window
        crud_window.geometry(f"800x600+{x}+{y}")
        
        # Rest of the code remains the same...
        
        # Configure CRUD window's grid
        crud_window.columnconfigure(0, weight=1)
        crud_window.rowconfigure(0, weight=1)
        
        crud_frame = ttk.Frame(crud_window, padding="10")
        crud_frame.grid(row=0, column=0, sticky="nsew")
        
        # Configure CRUD frame's grid
        crud_frame.columnconfigure(1, weight=1)
        crud_frame.rowconfigure(6, weight=1)
        
        # Table selection
        ttk.Label(crud_frame, text="Select Table:").grid(row=0, column=0, pady=5, sticky='e')
        tables = ["users", "alternate_identifiers", "events", "seats", 
                    "tickets", "payments", "reviews", "promotions"]
        table_var = tk.StringVar()
        table_combo = ttk.Combobox(crud_frame, textvariable=table_var, values=tables)
        table_combo.grid(row=0, column=1, pady=5, sticky='ew')
        
        # Search criteria
        ttk.Label(crud_frame, text="Search Criteria:").grid(row=1, column=0, pady=5, sticky='e')
        criteria_entry = ttk.Entry(crud_frame)
        criteria_entry.grid(row=1, column=1, pady=5, sticky='ew')
        
        # Column to update
        ttk.Label(crud_frame, text="Column to Update:").grid(row=2, column=0, pady=5, sticky='e')
        column_to_update_entry = ttk.Entry(crud_frame)
        column_to_update_entry.grid(row=2, column=1, pady=5, sticky='ew')
        
        # Update value
        ttk.Label(crud_frame, text="New Value:").grid(row=3, column=0, pady=5, sticky='e')
        update_value_entry = ttk.Entry(crud_frame)
        update_value_entry.grid(row=3, column=1, pady=5, sticky='ew')

        # Helper text
        ttk.Label(crud_frame, 
            text="Format for criteria: column=value (e.g., user_id=1)", 
            font=('Arial', 8, 'italic')).grid(row=4, column=0, columnspan=2, sticky='w', padx=5)

        # Buttons
        button_frame = ttk.Frame(crud_frame)
        button_frame.grid(row=5, column=0, columnspan=2, pady=10)
        
        ttk.Button(button_frame, text="Search Records", command=lambda: self.search_records(table_var, criteria_entry, result_text)).grid(row=0, column=0, padx=5)
        ttk.Button(button_frame, text="Read All Records", command=lambda: self.read_records(table_var, result_text)).grid(row=0, column=1, padx=5)
        ttk.Button(button_frame, text="Delete Records", command=lambda: self.delete_records(table_var, criteria_entry, result_text)).grid(row=0, column=2, padx=5)
        ttk.Button(button_frame, text="Update Records", command=lambda: self.update_records(table_var, criteria_entry, column_to_update_entry, update_value_entry, result_text)).grid(row=0, column=3, padx=5)

        # Results display
        result_text = scrolledtext.ScrolledText(crud_frame)
        result_text.grid(row=6, column=0, columnspan=2, pady=10, sticky="nsew")
    
    def update_records(self, table_var, criteria_entry, column_to_update_entry, update_value_entry, result_text):
        table = table_var.get()
        criteria = criteria_entry.get()
        column_to_update = column_to_update_entry.get()
        new_value = update_value_entry.get()
        
        if not table or not criteria or not column_to_update or not new_value:
            result_text.insert(tk.END, "Please select a table, enter criteria, column to update, and new value\n")
            return
            
        if messagebox.askyesno("Confirm Update", "Are you sure you want to update these records?"):
            try:
                cmd = f'''echo "2
{table}
{criteria}
{column_to_update}
{new_value}
5" | bash crud_operations.sh | grep -v "^Enter\|^Available\|^Select\|^===\|^-\|^$\|^[0-9]\."'''
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                result_text.delete(1.0, tk.END)
                result_text.insert(tk.END, result.stdout)
                if result.stderr:
                    result_text.insert(tk.END, f"\nErrors:\n{result.stderr}")
            except Exception as e:
                result_text.insert(tk.END, f"Error: {str(e)}\n")

    def search_records(self, table_var, criteria_entry, result_text):
        table = table_var.get()
        criteria = criteria_entry.get()
        
        if not table or not criteria:
            result_text.insert(tk.END, "Please select a table and enter search criteria\n")
            return
            
        try:
            cmd = f'''echo "4
{table}
{criteria}
5" | bash crud_operations.sh | grep -v "^Enter\|^Available\|^Select\|^===\|^-\|^$\|^[0-9]\."'''
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            result_text.delete(1.0, tk.END)
            result_text.insert(tk.END, result.stdout)
            if result.stderr:
                result_text.insert(tk.END, f"\nErrors:\n{result.stderr}")
        except Exception as e:
            result_text.insert(tk.END, f"Error: {str(e)}\n")

    def read_records(self, table_var, result_text):
        table = table_var.get()
        
        if not table:
            result_text.insert(tk.END, "Please select a table\n")
            return
            
        try:
            cmd = f'''echo "1
{table}
5" | bash crud_operations.sh | grep -v "^Enter\|^Available\|^Select\|^===\|^-\|^$\|^[0-9]\."'''
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            result_text.delete(1.0, tk.END)
            result_text.insert(tk.END, result.stdout)
            if result.stderr:
                result_text.insert(tk.END, f"\nErrors:\n{result.stderr}")
        except Exception as e:
            result_text.insert(tk.END, f"Error: {str(e)}\n")

    def delete_records(self, table_var, criteria_entry, result_text):
        table = table_var.get()
        criteria = criteria_entry.get()
        
        if not table or not criteria:
            result_text.insert(tk.END, "Please select a table and enter deletion criteria\n")
            return
            
        if messagebox.askyesno("Confirm Delete", "Are you sure you want to delete these records?"):
            try:
                cmd = f'''echo "3
{table}
{criteria}
y
5" | bash crud_operations.sh | grep -v "^Enter\|^Available\|^Select\|^===\|^-\|^$\|^[0-9]\."'''
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
                result_text.delete(1.0, tk.END)
                result_text.insert(tk.END, result.stdout)
                if result.stderr:
                    result_text.insert(tk.END, f"\nErrors:\n{result.stderr}")
            except Exception as e:
                result_text.insert(tk.END, f"Error: {str(e)}\n")

def main():
    root = tk.Tk()
    app = DatabaseGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
