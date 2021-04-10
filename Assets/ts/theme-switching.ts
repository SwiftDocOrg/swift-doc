type ThemeChoice = "light" | "dark" | "auto";
const themeQuery = window.matchMedia('(prefers-color-scheme: dark)');
const localStorageKey = "picked-theme";
let autoTheme = false;

// load initial theme before load event to prevent flashing of background color on navigation
let initialTheme = window.localStorage.getItem(localStorageKey) ?? "auto";
setPickedTheme(initialTheme as ThemeChoice);

window.addEventListener("load", () => {
    const themeSwitcher = window.document.getElementById("theme-switcher") as HTMLSelectElement;
    
    themeSwitcher.addEventListener("change", (themePickedEvent: Event) => {
        const newValue = (themePickedEvent.target as HTMLSelectElement).value
        setPickedTheme(newValue as ThemeChoice);
    });

    themeQuery.addEventListener?.("change", (systemThemeChangeEvent) => {
        const systemTheme = systemThemeChangeEvent.matches ? "dark" : "light";
        updateDropdownLabel(systemTheme);
        if (autoTheme) {
            applyTheme(systemTheme);
        }
    })

    setInitialTheme(themeSwitcher);
    checkThemingSupport();
})

/**
 * Sets the correct theme based on what's in storage, and updates the theme switcher dropdown with the correct initial value.
 */
function setInitialTheme(themeSwitcher: HTMLSelectElement) {
    let initialTheme = window.localStorage.getItem(localStorageKey) ?? "auto";
    themeSwitcher.value = initialTheme;
    setPickedTheme(initialTheme as ThemeChoice);
    const systemTheme = themeQuery.matches ? "dark" : "light";
    updateDropdownLabel(systemTheme);
}

/**
 * Updates the styles of the page to reflect a new theme
 */
function applyTheme(newTheme: "light" | "dark") {
    const otherTheme = newTheme == "light" ? "dark" : "light";
    window.document.documentElement.classList.remove(`${otherTheme}-theme`);
    window.document.documentElement.classList.add(`${newTheme}-theme`);
}

/**
 * Saves a newly picked theme to storage and applies the theme.
 * If the new theme is "auto", the correct theme will be applied based on the system settings.
 */
function setPickedTheme(newTheme: ThemeChoice) {
    window.localStorage.setItem(localStorageKey, newTheme);
    autoTheme = newTheme === "auto";
    if (newTheme === "auto") {
        const systemTheme = themeQuery.matches ? "dark" : "light";
        applyTheme(systemTheme);
    } else {
        applyTheme(newTheme);
    }
}

/**
 * Updates the "Auto" choice of the theme dropdown to reflect the current system theme - either "Auto (light)" or "Auto (dark)"
 */
function updateDropdownLabel(systemTheme: "light" | "dark") {
    window.document.getElementById('theme-option-auto').innerText = `Auto (${systemTheme})`;
}

/**
 * Checks whether color-scheme is a supported feature of the browser. 
 * If it is not, removes the auto option from the dropdown.
 */
function checkThemingSupport() {
    const darkQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const lightQuery = window.matchMedia('(prefers-color-scheme: light)');
    // If neither query matches, we know that the browser doesn't support theming.
    if (!darkQuery.matches && !lightQuery.matches) {
        const themeOptionAuto = window.document.getElementById('theme-option-auto');
        // IE doesn't support element.remove()
        themeOptionAuto.parentNode.removeChild(themeOptionAuto);
    }
    // If the browser does not support css properties, we do not allow theme switching.
    const customProperty = getComputedStyle(document.body).getPropertyValue("--body");
    if (!customProperty) {
        (document.querySelector(".theme-select-container") as HTMLDivElement).style.display = 'none';
    }
}
