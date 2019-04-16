currentUser = async () => {
    const response = await fetch('/current');
    return await response.json();
}