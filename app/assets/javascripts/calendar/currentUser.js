async function currentUser() {
    const response = await fetch('/current');
    console.log(response);
    return await response.json();
}