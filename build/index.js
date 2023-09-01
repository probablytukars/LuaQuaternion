const print = console.log;
const main = document.querySelector("main")
const sidebar = document.querySelector(".sidebar")
const sidebarlist = document.querySelector(".sidebar-list")
const searchbox = document.querySelector(".search-box-container")
const searchResults = document.querySelector(".search-results")
const searchBar = document.getElementById("api-search");
const clearSearch = document.querySelector('.clear-search')
const completeSearch = document.querySelector('.complete-search')
const headings = Array.from(document.querySelectorAll("h1[id], h2[id], h3[id], h4[id]")).map((el) => el.id);
const menuButton = document.querySelector(".menu-button")
const body = document.body
const checkbox = document.getElementById("checkbox")


checkbox.addEventListener("change", () => {
  body.classList.toggle("light-mode")
})

var debounce = 0

function sidebar_click(){
    var current_time = Date.now()
    if (current_time - debounce > 300)  {
        sidebar.classList.toggle("active")
        debounce = current_time
    }
}

function main_click() {
    if (sidebar.classList.contains("active")) {
        var current_time = Date.now()
        if (current_time - debounce > 300)  {
            sidebar.classList.toggle("active")
            debounce = current_time
        }
    }
}

menuButton.addEventListener("click", sidebar_click)
main.addEventListener("click", main_click)

const lightThemeMq = window.matchMedia("(prefers-color-scheme: light)");
function changeTheme(e) {
    if (e.matches) {
        body.classList.add("light-mode")
        checkbox.checked = false
    } else {
        body.classList.remove("light-mode")
        checkbox.checked = true
    }
}

changeTheme(lightThemeMq)
lightThemeMq.addEventListener("change", changeTheme)

const detectSizeChange = window.matchMedia("screen and (max-aspect-ratio: 3/4), screen and (max-width: 820px)");
detectSizeChange.addEventListener("change", (e) => {
    sidebar.classList.remove("active")
})





function searchFocus() {
    searchbox.classList.add("active")
}

function searchBlur() {
    searchbox.classList.remove("active")
    searchBar.value = ""
    deleteSearchResults()
}

const searchOptions = {
    threshold: -Infinity, 
    limit: 5, 
    all:false,
    allowTypo: true,
}

function createSearchElement(searchTarget) {
    const li = document.createElement("li")
    li.classList.add("search-result")
    const button = document.createElement("button")
    button.textContent = searchTarget
    const div = document.createElement("div")
    div.classList.add("divider", "horizontal")
    li.append(button)
    li.append(div)
    return li
}

function deleteSearchResults() {
    var children = searchResults.children
    for (i = 0; i < children.length; i++) {
        li = children[i]
        if (! li.classList.contains("no-results")) {
            li.removeEventListener("click", searchBlur)
        }
    }
}

function searchQuery() {
    const searchTerm = searchBar.value.trim().toLowerCase();
    const results = fuzzysort.go(searchTerm, headings, searchOptions)
    deleteSearchResults()
    clickClosures = []
    searchResults.replaceChildren()
    
    if (results.length > 0) {
        for (i = 0; i < results.length; i++) {
            let result = results[i]
            let searchTarget = result.target
            const li = document.createElement("li")
            li.classList.add("search-result")
            const a = document.createElement("a")
            a.textContent = searchTarget
            a.href = "#" + searchTarget
            const div = document.createElement("div")
            div.classList.add("divider", "horizontal")
            li.append(a)
            li.append(div)
            a.addEventListener("click", searchBlur)
            searchResults.append(li)
        }
    } else {
        const li = document.createElement("li")
        li.classList.add("search-result", "no-results")
        const span = document.createElement("span")
        span.textContent = "No results."
        li.append(span)
        searchResults.append(li)
    }
}

searchBar.addEventListener("focus", searchFocus)

function handleSearchBlur(e) {
    const withinBoundaries = e.composedPath().includes(searchbox)
    if (! withinBoundaries) {searchBlur()}
}

document.addEventListener('click', handleSearchBlur)
searchBar.addEventListener("focus", searchQuery)
searchBar.addEventListener("input", searchQuery);

clearSearch.addEventListener("click", () => {
    searchBlur()
    searchBar.focus()
})

function handleCompleteSearch() {
    const children = searchResults.children
    if (children.length > 0) {
        const targetElement = children[0]
        if (! targetElement.classList.contains("no-results")) {
            targetElement.firstChild.click()
        }
    }
}

var searchDebounce = 0
completeSearch.addEventListener("click", handleCompleteSearch)
searchBar.addEventListener("keydown", (e) => {
    const currentFocus = document.activeElement
    if (currentFocus == searchBar) {
        if (e.key == "Enter" || e.key == "Search") {
            handleCompleteSearch()
        } else if (e.key == "ArrowDown") {
            searchDebounce = Date.now()
            e.preventDefault()
            const children = searchResults.children
            if (children.length > 0) {
                const targetElement = searchResults.firstChild
                if (! targetElement.classList.contains("no-results")) {
                    const a = targetElement.firstChild;
                    a.focus()
                    targetElement.classList.add("focused")
                }
            }
        }
    }
})

function getIndexAndLength(focusedLi) {
    const children = searchResults.children
    const length = children.length
    for (i = 0; i < length; i++) {
        if (searchResults.children[i] == focusedLi) {
            return {i, length}
        }
    }
    return {i: -1, length}
}


document.addEventListener("keydown", (e) => {
    const currentFocus = document.activeElement
    if (currentFocus == searchBar || (Date.now() - searchDebounce) < 16) {
        return;
    }
    
    if (e.key == "/") {
        e.preventDefault()
        searchBar.focus()
        searchBar.value=""
        return;
    }
    if (currentFocus.parentElement.parentElement == searchResults) {
        const currentLi = currentFocus.parentElement
        const {i, length} = getIndexAndLength(currentLi)
        if (e.key == "ArrowDown") {
            e.preventDefault()
            if (i < length - 1) {
                currentLi.classList.remove("focused")
                const targetLi = searchResults.children[i + 1]
                targetLi.firstChild.focus()
                targetLi.classList.add("focused")
            }
        } else if (e.key == "ArrowUp") {
            e.preventDefault()
            if (i > 0) {
                currentLi.classList.remove("focused")
                const targetLi = searchResults.children[i - 1]
                targetLi.firstChild.focus()
                targetLi.classList.add("focused")
            }
            else {searchBar.focus()}
        }
    }
    
})

function getClosestScroll() {
    const headings = document.querySelectorAll("h1, h2, h3");
    let closestHeading = null;
    let closestDistance = Number.MAX_VALUE;
    const currentScroll = window.scrollY;
    
    headings.forEach(function(heading) {
        const computedStyle = getComputedStyle(heading);
        const marginTop = parseInt(computedStyle.marginTop);
        const headingRect = heading.getBoundingClientRect();
        const headingPosition = headingRect.top + currentScroll - marginTop;
        const distance = headingPosition - currentScroll;
        
        if (distance < closestDistance && distance > 0) {
            closestDistance = distance;
            closestHeading = heading;
        }
    });
    
    if (closestHeading != null) {
        const heading = closestHeading.textContent
        const sidebarItems = sidebarlist.children
        for (i = 0; i < sidebarItems.length; i++) {
            const sidebarItem = sidebarItems[i]
            const sidebarText = sidebarItem.firstChild.textContent;
            if (sidebarText == heading) {
                sidebarItem.classList.add("closest")
            } else {
                sidebarItem.classList.remove("closest")
            }
        }
    }
}

document.addEventListener("scroll", getClosestScroll);
getClosestScroll()



