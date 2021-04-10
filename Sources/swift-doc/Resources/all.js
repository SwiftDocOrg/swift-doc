var _a;
var themeQuery = window.matchMedia('(prefers-color-scheme: dark)');
var localStorageKey = "picked-theme";
var autoTheme = false;
// load initial theme before load event to prevent flashing of background color on navigation
var initialTheme = (_a = window.localStorage.getItem(localStorageKey)) !== null && _a !== void 0 ? _a : "auto";
setPickedTheme(initialTheme);
window.addEventListener("load", function () {
    var _a;
    var themeSwitcher = window.document.getElementById("theme-switcher");
    themeSwitcher.addEventListener("change", function (themePickedEvent) {
        var newValue = themePickedEvent.target.value;
        setPickedTheme(newValue);
    });
    (_a = themeQuery.addEventListener) === null || _a === void 0 ? void 0 : _a.call(themeQuery, "change", function (systemThemeChangeEvent) {
        var systemTheme = systemThemeChangeEvent.matches ? "dark" : "light";
        updateDropdownLabel(systemTheme);
        if (autoTheme) {
            applyTheme(systemTheme);
        }
    });
    setInitialTheme(themeSwitcher);
    checkThemingSupport();
});
/**
 * Sets the correct theme based on what's in storage, and updates the theme switcher dropdown with the correct initial value.
 */
function setInitialTheme(themeSwitcher) {
    var _a;
    var initialTheme = (_a = window.localStorage.getItem(localStorageKey)) !== null && _a !== void 0 ? _a : "auto";
    themeSwitcher.value = initialTheme;
    setPickedTheme(initialTheme);
    var systemTheme = themeQuery.matches ? "dark" : "light";
    updateDropdownLabel(systemTheme);
}
/**
 * Updates the styles of the page to reflect a new theme
 */
function applyTheme(newTheme) {
    var otherTheme = newTheme == "light" ? "dark" : "light";
    window.document.documentElement.classList.remove(otherTheme + "-theme");
    window.document.documentElement.classList.add(newTheme + "-theme");
}
/**
 * Saves a newly picked theme to storage and applies the theme.
 * If the new theme is "auto", the correct theme will be applied based on the system settings.
 */
function setPickedTheme(newTheme) {
    window.localStorage.setItem(localStorageKey, newTheme);
    autoTheme = newTheme === "auto";
    if (newTheme === "auto") {
        var systemTheme = themeQuery.matches ? "dark" : "light";
        applyTheme(systemTheme);
    }
    else {
        applyTheme(newTheme);
    }
}
/**
 * Updates the "Auto" choice of the theme dropdown to reflect the current system theme - either "Auto (light)" or "Auto (dark)"
 */
function updateDropdownLabel(systemTheme) {
    window.document.getElementById('theme-option-auto').innerText = "Auto (" + systemTheme + ")";
}
/**
 * Checks whether color-scheme is a supported feature of the browser.
 * If it is not, removes the auto option from the dropdown.
 */
function checkThemingSupport() {
    var darkQuery = window.matchMedia('(prefers-color-scheme: dark)');
    var lightQuery = window.matchMedia('(prefers-color-scheme: light)');
    // If neither query matches, we know that the browser doesn't support theming.
    if (!darkQuery.matches && !lightQuery.matches) {
        var themeOptionAuto = window.document.getElementById('theme-option-auto');
        // IE doesn't support element.remove()
        themeOptionAuto.parentNode.removeChild(themeOptionAuto);
    }
    // If the browser does not support css properties, we do not allow theme switching.
    var customProperty = getComputedStyle(document.body).getPropertyValue("--body");
    if (!customProperty) {
        document.querySelector(".theme-select-container").style.display = 'none';
    }
}
