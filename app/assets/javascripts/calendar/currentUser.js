async function currentUser() {
    const response = await fetch('/current');
    return await response.json();
}