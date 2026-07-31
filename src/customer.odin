package main

Customer :: struct {
	id:           int,
	name:         string,
	surname:      string,
	nationality:  string,
	picture_path: string,
}

Customer_State :: struct {
	current:           Maybe(Customer),
	next_roster_index: int,
	spawn_t:           f32,
}

CUSTOMER_SPAWN_DURATION :: f32(0.45)

customer_present :: proc(state: Customer_State) -> bool {
	return state.current != nil
}

update_customer_state :: proc(state: ^Customer_State, dt: f32) {
	if state.current != nil && state.spawn_t < 1 {
		state.spawn_t += dt / CUSTOMER_SPAWN_DURATION
		if state.spawn_t > 1 {
			state.spawn_t = 1
		}
	}
}

// Phase 1 only: cycles through the hardcoded roster in order.
// TODO: replace with next_generated_customer() once Phase 2 lands.
next_roster_customer :: proc(state: ^Customer_State) -> Customer {
	customer := customer_roster[state.next_roster_index % len(customer_roster)]
	state.next_roster_index += 1
	return customer
}

// Phase 1: small hardcoded roster to get the queue -> booth -> customer-panel
// spawn mechanic working end to end.
// TODO: replace with on-demand procedural generation (name/nationality pools
// combined at the moment a customer is called), like the real Papers, Please
// does for its walk-in customers - see project memory for the full plan.
// picture_path is the same placeholder for all of them for now - swap in
// per-customer art later.
CUSTOMER_PLACEHOLDER_PICTURE :: "assets/customers/customer.png"

customer_roster := []Customer {
	{id = 0, name = "Toran", surname = "Vessek", nationality = "Duskavia", picture_path = CUSTOMER_PLACEHOLDER_PICTURE},
	{id = 1, name = "Mira", surname = "Halden", nationality = "Brennoc", picture_path = CUSTOMER_PLACEHOLDER_PICTURE},
	{id = 2, name = "Josef", surname = "Kranik", nationality = "Ostrenia", picture_path = CUSTOMER_PLACEHOLDER_PICTURE},
	{id = 3, name = "Lysa", surname = "Vantor", nationality = "Duskavia", picture_path = CUSTOMER_PLACEHOLDER_PICTURE},
	{id = 4, name = "Petro", surname = "Danesh", nationality = "Brennoc", picture_path = CUSTOMER_PLACEHOLDER_PICTURE},
}
