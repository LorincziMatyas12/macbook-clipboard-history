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
    ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```
-   Install Git with Homebrew
    ```
    brew install git
    ```

**2. Cloning the repository**

-   Open the terminal and run the following command to clone the repository
    ```
    git clone https://github.com/LorincziMatyas12/macbook-clipboard-history.git
    ```

**3. Using the program (script)**

-   Run the following command to grant execute permissions. You olny have to do this once.
    ```
    chmod u+x /path/to/clipboard-history.sh
    ```
-   Running the script: Each time you restart your computer, you will need to start the program manually.
    ```
    ./path/to/clipboard-history.sh --start
    ```
-   To see the clipboard window run the following command:
    ```
    ./path/to/clipboard-history.sh --show
    ```
-   Stopping the script
    ```
    ./path/to/clipboard-history.sh --stop
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
    ```bash
    /path/to/clipboard-history.sh --show
    ```
-   Click the **Play** button to test it. You should see the clipboard history window.
-   Save the workflow.
-   Open **System Settings > Keyboard > Keyboard Shortcuts...**
-   Navigate to **Services > General > Name_Of_The_Workflow**
-   Check the checkbox, then double-click the darker **"none"** box.
-   Press **Command + Shift + V** to set the shortcut, then click **Done**.

##
