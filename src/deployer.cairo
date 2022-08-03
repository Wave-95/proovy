%lang starknet

from cairo_contracts.src.openzeppelin.access.ownable.library import Ownable
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import deploy
from starkware.cairo.common.alloc import alloc

@storage_var
func salt() -> (salt : felt):
end

@storage_var
func class_hash_OZ_ERC721MintableBurnable() -> (class_hash : felt):
end

@event
func contract_deployed(contract_address : felt, contract_owner : felt):
end

@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(owner : felt):
    Ownable.initializer(owner=owner)
    return ()
end

#
# Class hash setters
#

@external
func set_OZ_ERC721MintableBurnable{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(class_hash : felt):
    Ownable.assert_only_owner()
    class_hash_OZ_ERC721MintableBurnable.write(value=class_hash)
    return ()
end

#
# Deploy calls
#

@external
func deploy_OZ_ERC721MintableBurnable{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(
    name : felt,
    symbol : felt,
    owner : felt
):
    let (current_salt) = salt.read()
    let (class_hash) = class_hash_OZ_ERC721MintableBurnable.read()
    let (constructor_args : felt*) = alloc()
    assert constructor_args[0] = name
    assert constructor_args[1] = symbol
    assert constructor_args[2] = owner

    let (contract_address) = deploy(
        class_hash=class_hash,
        contract_address_salt=current_salt,
        constructor_calldata_size=3,
        constructor_calldata=constructor_args,
        deploy_from_zero=0,
    )
    salt.write(value=current_salt + 1)
    contract_deployed.emit(contract_address=contract_address, contract_owner=owner)
    return()
end

#
# Owner calls
#

@view
func get_owner{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}() -> (owner : felt):
    let (owner) = Ownable.owner()
    return(owner=owner)
end

@external
func change_owner{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(new_owner : felt):
    Ownable.transfer_ownership(new_owner=new_owner)
    return()
end
