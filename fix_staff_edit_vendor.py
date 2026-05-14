"""Fix staff edit_vendor.dart: insert missing Password, buttons, mobile layout, and CustomTextField class."""

path = 'lib/StaffModule/screen/Maintenance/Vendor/edit_vendor.dart'

with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Keep lines 1-1299 (index 0-1298), then insert new code, then keep the rest (commented old code)
kept = lines[:1299]

new_code = '''                              const SizedBox(
                                height: 10,
                              ),
                              Text('Password *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      keyboardType: TextInputType.text,
                                      obscureText: obsecure,
                                      hintText: 'Enter password',
                                      controller: passWord,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'please enter password';
                                        }
                                        return null;
                                      },
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            obsecure = !obsecure;
                                          });
                                        },
                                        child: Icon(
                                          !obsecure
                                              ? CupertinoIcons.eye_slash_fill
                                              : CupertinoIcons.eye_fill,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      pass: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text('Confirm Password *',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      keyboardType: TextInputType.text,
                                      obscureText: conobsecure,
                                      hintText: 'Re-enter password',
                                      controller: conpassWord,
                                      validator: (value) {
                                        if (value == null) {
                                          return 'please enter confirm password';
                                        }
                                        return null;
                                      },
                                      pass: true,
                                      passwordController: passWord,
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            conobsecure = !conobsecure;
                                          });
                                        },
                                        child: Icon(
                                          !conobsecure
                                              ? CupertinoIcons.eye_slash_fill
                                              : CupertinoIcons.eye_fill,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: blueColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () async {
                                          bool isFormValid = true;
                                          if (firstName.text.isEmpty) setState(() { isFormValid = false; });
                                          if (phoneNumber.text.isEmpty) setState(() { isFormValid = false; });
                                          if (email.text.isEmpty) setState(() { isFormValid = false; });

                                          bool hasChanges = firstName.text != initialVendorName ||
                                              phoneNumber.text != initialPhoneNumber ||
                                              email.text != initialEmail ||
                                              passWord.text != initialPassword ||
                                              selectedTradeType != initialTradeType;

                                          if (!hasChanges) { Navigator.of(context).pop(false); return; }
                                          if (!isFormValid) return;

                                          setState(() { isLoading = true; });
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          String adminId = prefs.getString("adminId")!;

                                          final vendor = Vendor(
                                            adminId: adminId,
                                            vendorName: firstName.text,
                                            vendorPhoneNumber: phoneNumber.text,
                                            vendorEmail: email.text,
                                            vendorPassword: passWord.text,
                                            trade: selectedTradeType,
                                          );
                                          final success = await vendorRepository.update_vendor(vendor, widget.vender_id!);
                                          setState(() { isLoading = false; });
                                          if (success) {
                                            Fluttertoast.showToast(msg: "Vendor Edited successfully");
                                            Navigator.of(context).pop(true);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to edit vendor')));
                                          }
                                        },
                                        child: isLoading
                                            ? const Center(child: SpinKitFadingCircle(color: Colors.white, size: 55.0))
                                            : const Text('Edit Vendor', style: TextStyle(color: Color(0xFFf7f8f9))),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFffffff),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () { Navigator.pop(context); },
                                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF748097))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBar(
                      width: MediaQuery.of(context).size.width * .94,
                      title: 'Edit Vendor',
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: const Color(0xFFE0E0E0),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vendor Name *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              hintText: 'Enter vendor name',
                              controller: firstName,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the vendor name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Text('Phone Number *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.number,
                              hintText: 'Enter phone number',
                              controller: phoneNumber,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter the phone number';
                                }
                                return null;
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                                PhoneNumberFormatter(),
                              ],
                              phone: true,
                            ),
                            const SizedBox(height: 10),
                            Text('Email *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.emailAddress,
                              hintText: 'Enter email',
                              controller: email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'please enter email';
                                }
                                return null;
                              },
                              email: true,
                            ),
                            const SizedBox(height: 10),
                            // Trade Type commented out
                            const SizedBox(height: 10),
                            Text('Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              obscureText: obsecure,
                              hintText: 'Enter password',
                              controller: passWord,
                              validator: (value) {
                                if (value == null) {
                                  return 'please enter password';
                                }
                                return null;
                              },
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    obsecure = !obsecure;
                                  });
                                },
                                child: Icon(
                                  !obsecure
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye_fill,
                                  color: Colors.grey,
                                ),
                              ),
                              pass: true,
                            ),
                            const SizedBox(height: 10),
                            Text('Confirm Password *',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor)),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.text,
                              obscureText: conobsecure,
                              hintText: 'Re-enter password',
                              controller: conpassWord,
                              validator: (value) {
                                if (value == null) {
                                  return 'please enter confirm password';
                                }
                                return null;
                              },
                              pass: true,
                              passwordController: passWord,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    conobsecure = !conobsecure;
                                  });
                                },
                                child: Icon(
                                  !conobsecure
                                      ? CupertinoIcons.eye_slash_fill
                                      : CupertinoIcons.eye_fill,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 35),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formkey.currentState!.validate()) {
                                          bool isFormValid = true;
                                          if (firstName.text.trim().isEmpty) setState(() { isFormValid = false; });
                                          if (phoneNumber.text.trim().isEmpty) setState(() { isFormValid = false; });
                                          if (email.text.trim().isEmpty) setState(() { isFormValid = false; });

                                          bool hasChanges = firstName.text != initialVendorName ||
                                              phoneNumber.text != initialPhoneNumber ||
                                              email.text != initialEmail ||
                                              passWord.text != initialPassword ||
                                              selectedTradeType != initialTradeType;

                                          if (!hasChanges) { Navigator.of(context).pop(false); return; }
                                          if (!isFormValid) return;

                                          setState(() { isLoading = true; });
                                          SharedPreferences prefs = await SharedPreferences.getInstance();
                                          String adminId = prefs.getString("adminId")!;

                                          final vendor = Vendor(
                                            adminId: adminId,
                                            vendorName: firstName.text.trim(),
                                            vendorPhoneNumber: phoneNumber.text.trim(),
                                            vendorEmail: email.text.trim(),
                                            vendorPassword: passWord.text.trim(),
                                            trade: selectedTradeType,
                                          );
                                          final success = await vendorRepository
                                              .update_vendor(vendor, widget.vender_id!);
                                          setState(() { isLoading = false; });
                                          if (success) {
                                            Fluttertoast.showToast(msg: "Vendor Edited successfully");
                                            Navigator.of(context).pop(true);
                                          } else {
                                            print("Failed to edit vendor");
                                          }
                                        }
                                      },
                                      child: isLoading
                                          ? const Center(child: SpinKitFadingCircle(color: Colors.white, size: 55.0))
                                          : const Text('Edit Vendor', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFf7f8f9))),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFffffff),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: () { Navigator.pop(context); },
                                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF748097))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

'''

custom_text_field = '''class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Function(String)? onChanged;
  final Function(String)? onChanged2;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function()? onTap;
  final bool readOnnly;
  bool? optional;
  final bool? pass;
  final bool? email;
  final bool? phone;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController?
      passwordController;

  CustomTextField({
    Key? key,
    this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.emailAddress,
    this.readOnnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSuffixIconPressed,
    this.onTap,
    this.onChanged,
    this.optional,
    this.onChanged2,
    this.pass,
    this.email,
    this.phone,
    this.inputFormatters,
    this.passwordController,
  }) : super(key: key);

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  String? _errorMessage;
  TextEditingController _textController =
      TextEditingController();

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    if (widget.passwordController != null && widget.controller != null) {
      widget.passwordController!.addListener(_validateConfirmPassword);
      widget.controller!.addListener(_validateConfirmPassword);
    }
  }

  void _validateConfirmPassword() {
    if (widget.passwordController != null && widget.controller != null) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.passwordController != null) {
      widget.passwordController!.removeListener(_validateConfirmPassword);
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(_validateConfirmPassword);
    }
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      actions: [
        KeyboardActionsItem(
          focusNode: _focusNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () {
                  if (widget.onChanged2 != null) {
                    widget.onChanged2!(_textController.text);
                  }
                  node.unfocus();
                },
                child: const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Text(
                    "Done",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseKeyboardActions =
        widget.keyboardType == TextInputType.number;
    Widget textfield = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        FormField<String>(
          validator: widget.optional != null
              ? null
              : (value) {
                  if (widget.controller!.text.trim().isEmpty) {
                    setState(() {
                      String hintTextLower = widget.hintText.isEmpty
                          ? widget.hintText
                          : widget.hintText[0].toLowerCase() +
                              widget.hintText.substring(1);
                      _errorMessage = 'Please $hintTextLower';
                    });
                    return '';
                  } else if (widget.phone != null) {
                    String formattedPhoneNumber = widget.controller!.text
                        .trim()
                        .replaceAll(RegExp(r\'\\D\'), \'\');
                    if (formattedPhoneNumber.length != 10) {
                      setState(() {
                        _errorMessage = "Phone number must be 10 digits";
                      });
                      return '';
                    }
                  } else if (widget.email != null) {
                    if (!EmailValidator.validate(
                        widget.controller!.text.trim())) {
                      setState(() {
                        _errorMessage = "Email is not valid";
                      });
                      return '';
                    }
                  } else if (widget.pass != null) {
                    if (widget.passwordController != null &&
                        widget.controller != null) {
                      if (widget.controller!.text.trim() !=
                          widget.passwordController!.text.trim()) {
                        setState(() {
                          _errorMessage = "Passwords do not match";
                        });
                        return '';
                      }
                    } else {
                      String? validationMessage =
                          ValidatePassword(widget.controller!.text.trim());
                      if (validationMessage != null) {
                        setState(() {
                          _errorMessage = validationMessage;
                        });
                        return '';
                      }
                    }
                  }
                  setState(() {
                    _errorMessage = null;
                  });
                  return null;
                },
          builder: (FormFieldState<String> state) {
            return Column(
              children: <Widget>[
                Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.0),
                  ),
                  child: TextFormField(
                    onTap: widget.onTap,
                    obscureText: widget.obscureText,
                    readOnly: widget.readOnnly,
                    keyboardType: widget.keyboardType,
                    focusNode: _focusNode,
                    onChanged: (value) {
                      if (widget.onChanged != null) {
                        widget.onChanged!(value);
                      }
                      if (widget.passwordController != null ||
                          widget.pass != null) {
                        state.didChange(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        state.validate();
                      }
                      return null;
                    },
                    controller: widget.controller,
                    inputFormatters: widget.inputFormatters ?? [],
                    decoration: InputDecoration(
                      suffixIcon: widget.suffixIcon,
                      hintStyle: const TextStyle(
                          fontSize: 13, color: Color(0xFFb0b6c3)),
                      border: InputBorder.none,
                      hintText: widget.hintText,
                    ),
                  ),
                ),
                if (state.hasError)
                  const SizedBox(height: 24),
              ],
            );
          },
        ),
        if (_errorMessage != null)
          Positioned(
            top: 60,
            left: 8,
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
    return shouldUseKeyboardActions
        ? SizedBox(
            height: _errorMessage != null ? 75 : 60,
            width: MediaQuery.of(context).size.width * .98,
            child: KeyboardActions(
              config: _buildConfig(context),
              child: textfield,
            ),
          )
        : textfield;
  }
}
'''

# Build result: kept lines + new code + old commented lines + CustomTextField class
old_rest = lines[1299:]  # all the commented old code

result = kept + [line + '\n' if not line.endswith('\n') else line for line in new_code.split('\n')[:-1]]
# Actually just append new_code as a string
result = ''.join(kept) + new_code + ''.join(old_rest) + custom_text_field

with open(path, 'w', encoding='utf-8') as f:
    f.write(result)

print("Done. Verifying...")
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()
    clines = content.split('\n')

trade_ui = sum(1 for l in clines if 'Trade Type *' in l and not l.lstrip().startswith('//'))
trade_api = sum(1 for l in clines if 'trade: selectedTradeType' in l and not l.lstrip().startswith('//'))
password = sum(1 for l in clines if 'Password *' in l and not l.lstrip().startswith('//'))
button = sum(1 for l in clines if 'ElevatedButton(' in l and not l.lstrip().startswith('//'))
custom_tf = sum(1 for l in clines if 'class CustomTextField' in l and not l.lstrip().startswith('//'))

print(f'  TradeType UI={trade_ui} (want 0)')
print(f'  trade API={trade_api} (want 2)')
print(f'  Password labels={password} (want 4)')
print(f'  ElevatedButton={button} (want 4)')
print(f'  CustomTextField class={custom_tf} (want 1)')
print(f'  Total lines: {len(clines)}')
