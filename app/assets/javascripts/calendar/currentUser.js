/**
 * returns the current user from the users_controller
 * used in calendar and modals
 */
currentUser = async () => {
    const response = await fetch('/current');
    return await response.json();
}