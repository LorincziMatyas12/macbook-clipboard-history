<!-- @format -->

# MacOS clipboard manager

## Project information

This project was inspired by the Clipboard History (Clipboard Manager) feature in Microsoft Windows.

## Functionatity

The core functionality is based on being able to view your MacOS clipboard history.
When you start the script, it listens for clipboard activity. Every time you copy something using '**Command + C**', the script saves it. When you press '**Command + Shift + V**', a dialog pops up displaying the last 10 copied items. Click on the text you need, press '**Ok**' and then paste it using Command + V.

## Running it on your device

**1. If Git is not already installed on your system, follow the instructions below. Otherwise, you can skip this step.**

-   Install Homebrew with this command or visit their website for further information (https://brew.sh)
    ```console
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
-   Install Git with Homebrew, and check the version
    ```console
    brew install git
    git version
    ```

**2. Cloning the repository**

-   Open the terminal and run the following command to clone the repository

    ```console
    git clone https://github.com/LorincziMatyas12/macbook-clipboard-history.git
    ```

-   Open the **clipboard_history.sh** file and change the path to where you cloned the repository. You can use the text editor of your choice.

    ```sh
    HISTORY_FILE="$HOME/path/to/macos-clipboard-history/.env/.clipboard_history.json"

    PID_FILE="$HOME/path/to/macos-clipboard-history/.env/.clipboard_listener_pid"
    ```

    "**/path/to/**" If you cloned the repository to **Documents** it should look something like this:

    ```sh
    HISTORY_FILE="$HOME/Documents/macos-clipboard-history/.env/.clipboard_history.json"

    PID_FILE="$HOME/Documents/macos-clipboard-history/.env/.clipboard_listener_pid"
    ```

**3. Using the program (script)**

-   Make shure that python3 is installed on your laptop. If not follow the instructions on the official site. https://www.python.org/downloads/macos/
-   You can also install python3 with Homebrew. Chech the version with the following command
    ```console
    brew install python
    python --version
    ```

-   Run the following command to grant execute permissions to your user. You olny have to do this once. (Navigate to the project folder with **"cd"** command, than you don't have to include the **"/path/to/"** in the following commands)
    ```console
    chmod u+x /path/to/clipboard_history.sh
    ```
    You can list all the files in the project folder with **"ls -l"**, you should see something like **"-rwxr--r--"** permissions.
    
-   Running the script: Each time you restart your computer, you will need to start the program manually.
    ```console
    ./path/to/clipboard_history.sh --start
    ```
-   Run this command so you can close the terminal afterwards
    ```console
    nohup /path/to/macos-clipboard-history/clipboard_history.sh --start &
    ```
-   To see the clipboard window run the following command:
    ```console
    ./path/to/clipboard_history.sh --show
    ```
-   Stopping the script
    ```console
    ./path/to/clipboard_history.sh --stop
    ```

**4. Creating a Shortcut to View Clipboard History**

-   Open the **Automator** app on your Mac.
-   Create a **Workflow**.
-   Add a **"Run Shell Script"** action to the workflow.
-   Ensure the following setting is applied in the workflow:
    -   **"Workflow receives 'no input' in 'any application'"**
-   For **"Run Shell Script"**, set:
    -   **Shell:** `/bin/bash`
    -   **Pass input:** `to stdin`
-   Paste the following command into the script box:
    ```console
    /path/to/clipboard_history.sh --show
    ```
-   Click the **Play** button to test it. You should see the clipboard history window.
-   Save the workflow.
-   Open **System Settings > Keyboard > Keyboard Shortcuts...**
-   Navigate to **Services > General > Name_Of_The_Workflow**
-   Check the checkbox, then double-click the darker **"none"** box.
-   Press **Command + Shift + V** to set the shortcut, then click **Done**.

**5. Possible fixes for errors**
-   Grant **"Full Disk Access"** for Terminal and Automator in your system settings. Open **System Settings** and navigate to **Privacy & Security > Full Disk Access** click on the **"+"** button and select Automator and Terminal
