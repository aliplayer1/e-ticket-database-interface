import subprocess
import os

def main():
    """Run the menu.sh script once."""
    script_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "menu.sh")

    # Check if the script exists
    if not os.path.exists(script_path):
        print(f"Error: Script not found at {script_path}")
        return

    # Run the menu.sh script
    try:
        subprocess.run(["bash", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running the script: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()